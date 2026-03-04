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

        @host = @wiremock.host
        @http_port = @wiremock.mapped_port(8080)
        @https_port = @wiremock.mapped_port(8443)

        register_wiremock_stubs
      end
      # rubocop:enable Metrics/MethodLength

      def after_all
        @wiremock&.stop
        super
      end

      def test_custom_ca_cert
        zitadel = ::Zitadel::Client::Zitadel.with_client_credentials(
          "https://#{@host}:#{@https_port}",
          'dummy-client', 'dummy-secret',
          ca_cert_path: @ca_cert_path
        )

        refute_nil zitadel
      end

      def test_insecure_mode
        zitadel = ::Zitadel::Client::Zitadel.with_client_credentials(
          "https://#{@host}:#{@https_port}",
          'dummy-client', 'dummy-secret',
          insecure: true
        )

        refute_nil zitadel
      end

      # rubocop:disable Metrics/MethodLength
      def test_default_headers
        # Use HTTP to avoid TLS concerns
        zitadel = ::Zitadel::Client::Zitadel.with_client_credentials(
          "http://#{@host}:#{@http_port}",
          'dummy-client', 'dummy-secret',
          default_headers: { 'X-Custom-Header' => 'test-value' }
        )

        refute_nil zitadel

        # Verify via WireMock request journal
        # noinspection HttpUrlsUsage
        journal_uri = URI("http://#{@host}:#{@http_port}/__admin/requests")
        journal = JSON.parse(Net::HTTP.get(journal_uri))

        found_header = journal['requests'].any? do |req|
          req.dig('request', 'headers', 'X-Custom-Header')
        end

        assert found_header, 'Custom header should be present in WireMock request journal'
      end
      # rubocop:enable Metrics/MethodLength

      def test_proxy_url
        zitadel = ::Zitadel::Client::Zitadel.with_client_credentials(
          "http://#{@host}:#{@http_port}",
          'dummy-client', 'dummy-secret',
          proxy_url: "http://#{@host}:#{@http_port}"
        )

        refute_nil zitadel
      end

      def test_no_ca_cert_fails
        assert_raises(StandardError) do
          ::Zitadel::Client::Zitadel.with_client_credentials(
            "https://#{@host}:#{@https_port}",
            'dummy-client', 'dummy-secret'
          )
        end
      end

      def test_transport_options_object
        opts = TransportOptions.new(insecure: true)
        zitadel = Zitadel.with_client_credentials(
          "https://#{@host}:#{@https_port}",
          'dummy-client', 'dummy-secret',
          transport_options: opts
        )

        assert_instance_of Zitadel, zitadel
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
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
