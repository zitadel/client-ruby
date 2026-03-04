# frozen_string_literal: true

# Test suite for transport options (default_headers, ca_cert_path, insecure).
#
# Uses a WireMock Docker container with HTTPS support to verify that the SDK
# correctly handles custom CA certificates, insecure TLS mode, and custom
# default headers when initializing via `with_client_credentials`.

# noinspection RubyResolve
require 'test_helper'
require 'minitest/autorun'
require 'minitest/hooks/test'
require 'testcontainers'
require 'docker'
require 'net/http'
require 'json'

FIXTURES_DIR = File.join(__dir__, '..', '..', 'fixtures')

module Zitadel
  module Client
    class TransportOptionsTest < Minitest::Test # rubocop:disable Metrics/ClassLength
      # noinspection RbsMissingTypeSignature
      include Minitest::Hooks

      # rubocop:disable Metrics/MethodLength
      def before_all
        super

        @ca_cert_path = File.join(FIXTURES_DIR, 'ca.pem')
        keystore_path = File.join(FIXTURES_DIR, 'keystore.p12')
        tinyproxy_conf = File.join(FIXTURES_DIR, 'tinyproxy.conf')

        @network = Docker::Network.create('zitadel-proxy-test')

        @wiremock = Testcontainers::DockerContainer.new('wiremock/wiremock:3.3.1')
                                                   .with_filesystem_binds("#{keystore_path}:/home/wiremock/keystore.p12:ro")
                                                   .with_command(
                                                     '--https-port', '8443',
                                                     '--https-keystore', '/home/wiremock/keystore.p12',
                                                     '--keystore-password', 'password',
                                                     '--keystore-type', 'PKCS12',
                                                     '--global-response-templating'
                                                   )
                                                   .with_exposed_ports(8080, 8443)
                                                   .start
        @wiremock.wait_for_http(container_port: 8080, path: '/__admin/mappings', status: 200)

        # Connect WireMock to network with alias so the proxy can resolve it
        wiremock_id = @wiremock.instance_variable_get(:@_id)
        @network.connect(wiremock_id, {}, 'EndpointConfig' => { 'Aliases' => ['wiremock'] })

        # Create proxy directly on the network so Docker DNS resolves 'wiremock'
        Docker::Image.create('fromImage' => 'vimagick/tinyproxy')
        @proxy_container = Docker::Container.create(
          'Image' => 'vimagick/tinyproxy',
          'ExposedPorts' => { '8888/tcp' => {} },
          'HostConfig' => {
            'PortBindings' => { '8888/tcp' => [{ 'HostPort' => '' }] },
            'Binds' => ["#{tinyproxy_conf}:/etc/tinyproxy/tinyproxy.conf:ro"],
            'NetworkMode' => 'zitadel-proxy-test'
          }
        )
        @proxy_container.start

        @host = @wiremock.host
        @http_port = @wiremock.mapped_port(8080)
        @https_port = @wiremock.mapped_port(8443)
        @proxy_container.refresh!
        @proxy_port = @proxy_container.json['NetworkSettings']['Ports']['8888/tcp'].first['HostPort'].to_i

        register_wiremock_stubs
      end
      # rubocop:enable Metrics/MethodLength

      def after_all
        @proxy_container&.stop
        @proxy_container&.remove
        @wiremock&.stop
        @network&.remove
        super
      end

      def test_custom_ca_cert
        zitadel = ::Zitadel::Client::Zitadel.with_client_credentials(
          "https://#{@host}:#{@https_port}",
          'dummy-client', 'dummy-secret',
          transport_options: TransportOptions.new(ca_cert_path: @ca_cert_path)
        )

        refute_nil zitadel
      end

      def test_insecure_mode
        zitadel = ::Zitadel::Client::Zitadel.with_client_credentials(
          "https://#{@host}:#{@https_port}",
          'dummy-client', 'dummy-secret',
          transport_options: TransportOptions.new(insecure: true)
        )

        refute_nil zitadel
      end

      # rubocop:disable Metrics/MethodLength
      def test_default_headers
        # Use HTTP to avoid TLS concerns
        opts = TransportOptions.new(default_headers: { 'X-Custom-Header' => 'test-value' })
        zitadel = ::Zitadel::Client::Zitadel.with_client_credentials(
          "http://#{@host}:#{@http_port}",
          'dummy-client', 'dummy-secret',
          transport_options: opts
        )

        refute_nil zitadel

        # Make an actual API call to verify headers propagate to service requests
        zitadel.settings.get_general_settings({})

        # Use WireMock's verification API to assert the header was sent on the API call
        # noinspection HttpUrlsUsage
        verify_uri = URI("http://#{@host}:#{@http_port}/__admin/requests/count")
        verify_response = Net::HTTP.post(verify_uri, {
          url: '/zitadel.settings.v2.SettingsService/GetGeneralSettings',
          headers: { 'X-Custom-Header' => { 'equalTo' => 'test-value' } }
        }.to_json, 'Content-Type' => 'application/json')

        count = JSON.parse(verify_response.body)['count']

        assert_operator count, :>=, 1, 'Custom header should be present on API call'
      end
      # rubocop:enable Metrics/MethodLength

      def test_proxy_url
        # Use Docker-internal hostname — only resolvable through the proxy's network
        zitadel = ::Zitadel::Client::Zitadel.with_access_token(
          'http://wiremock:8080',
          'test-token',
          transport_options: TransportOptions.new(proxy_url: "http://#{@host}:#{@proxy_port}")
        )

        refute_nil zitadel
        zitadel.settings.get_general_settings({})
      end

      def test_no_ca_cert_fails
        assert_raises(StandardError) do
          ::Zitadel::Client::Zitadel.with_client_credentials(
            "https://#{@host}:#{@https_port}",
            'dummy-client', 'dummy-secret'
          )
        end
      end

      private

      # rubocop:disable Metrics/MethodLength
      def register_wiremock_stubs
        # noinspection HttpUrlsUsage
        uri = URI("http://#{@host}:#{@http_port}/__admin/mappings")

        # Stub 1 - OpenID Configuration
        response = Net::HTTP.post(uri, {
          request: { method: 'GET', url: '/.well-known/openid-configuration' },
          response: {
            status: 200,
            headers: { 'Content-Type' => 'application/json' },
            body: '{"issuer":"{{request.baseUrl}}",' \
                  '"token_endpoint":"{{request.baseUrl}}/oauth/v2/token",' \
                  '"authorization_endpoint":"{{request.baseUrl}}/oauth/v2/authorize",' \
                  '"userinfo_endpoint":"{{request.baseUrl}}/oidc/v1/userinfo",' \
                  '"jwks_uri":"{{request.baseUrl}}/oauth/v2/keys"}'
          }
        }.to_json, 'Content-Type' => 'application/json')

        assert_equal '201', response.code

        # Stub 2 - Token endpoint
        response = Net::HTTP.post(uri, {
          request: { method: 'POST', url: '/oauth/v2/token' },
          response: {
            status: 200,
            headers: { 'Content-Type' => 'application/json' },
            jsonBody: { access_token: 'test-token-12345', token_type: 'Bearer', expires_in: 3600 }
          }
        }.to_json, 'Content-Type' => 'application/json')

        assert_equal '201', response.code

        # Stub 3 - Settings API endpoint (for verifying headers on API calls)
        response = Net::HTTP.post(uri, {
          request: { method: 'POST', url: '/zitadel.settings.v2.SettingsService/GetGeneralSettings' },
          response: {
            status: 200,
            headers: { 'Content-Type' => 'application/json' },
            jsonBody: {}
          }
        }.to_json, 'Content-Type' => 'application/json')

        assert_equal '201', response.code
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
