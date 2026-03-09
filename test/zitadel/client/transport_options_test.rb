# frozen_string_literal: true

require 'test_helper'
require 'minitest/autorun'
require 'minitest/hooks/test'
require 'testcontainers'
require 'docker'
require 'net/http'
require 'json'
require 'securerandom'

FIXTURES_DIR = File.join(__dir__, '..', '..', 'fixtures')

module Zitadel
  module Client
    class TransportOptionsTest < Minitest::Test # rubocop:disable Metrics/ClassLength
      include Minitest::Hooks

      # rubocop:disable Metrics/MethodLength
      def before_all
        super

        @ca_cert_path = File.join(FIXTURES_DIR, 'ca.pem')
        keystore_path = File.join(FIXTURES_DIR, 'keystore.p12')
        squid_conf = File.join(FIXTURES_DIR, 'squid.conf')

        @network_name = "zitadel-test-#{SecureRandom.hex(4)}"
        @network = Docker::Network.create(@network_name)

        mappings_dir = File.join(FIXTURES_DIR, 'mappings')

        @wiremock = Testcontainers::DockerContainer.new('wiremock/wiremock:3.12.1')
                                                   .with_filesystem_binds(
                                                     "#{keystore_path}:/home/wiremock/keystore.p12:ro",
                                                     "#{mappings_dir}:/home/wiremock/mappings:ro"
                                                   )
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

        wiremock_id = @wiremock._id
        @network.connect(wiremock_id, {}, 'EndpointConfig' => { 'Aliases' => ['wiremock'] })

        @proxy = Testcontainers::DockerContainer.new('ubuntu/squid:6.10-24.10_beta')
                                                .with_filesystem_binds("#{squid_conf}:/etc/squid/squid.conf:ro")
                                                .with_exposed_ports(3128)
                                                .start
        @proxy.wait_for_tcp_port(3128)
        @network.connect(@proxy._id)

        @host = @wiremock.host
        @http_port = @wiremock.mapped_port(8080)
        @https_port = @wiremock.mapped_port(8443)
        @proxy_port = @proxy.mapped_port(3128)

      end
      # rubocop:enable Metrics/MethodLength

      def after_all
        @proxy&.stop
        @proxy&.remove
        @wiremock&.stop
        @wiremock&.remove
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
        opts = TransportOptions.new(default_headers: { 'X-Custom-Header' => 'test-value' })
        zitadel = ::Zitadel::Client::Zitadel.with_client_credentials(
          "http://#{@host}:#{@http_port}",
          'dummy-client', 'dummy-secret',
          transport_options: opts
        )

        refute_nil zitadel

        zitadel.settings.get_general_settings({})

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

    end
  end
end
