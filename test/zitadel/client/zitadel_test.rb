# frozen_string_literal: true

require 'test_helper'
require 'minitest/autorun'
require 'minitest/hooks/test'
require 'testcontainers'
require 'docker'
require 'securerandom'

FIXTURES_DIR = File.join(__dir__ || '.', '..', '..', 'fixtures')

WIREMOCK_COMMAND = [
  '--https-port', '8443',
  '--https-keystore', '/home/wiremock/keystore.p12',
  '--keystore-password', 'password',
  '--keystore-type', 'PKCS12',
  '--global-response-templating'
].freeze

module Zitadel
  module Client
    class ZitadelTest < Minitest::Test
      include Minitest::Hooks

      def before_all
        super

        @ca_cert_path = File.join(FIXTURES_DIR, 'ca.pem')
        @network = Docker::Network.create("zitadel-test-#{SecureRandom.hex(4)}")

        @wiremock = start_wiremock
        @network.connect(@wiremock._id, {}, 'EndpointConfig' => { 'Aliases' => ['wiremock'] })
        @proxy = start_proxy
        @network.connect(@proxy._id)

        capture_endpoints
      end

      def capture_endpoints
        @host = @wiremock.host
        @http_port = @wiremock.mapped_port(8080)
        @https_port = @wiremock.mapped_port(8443)
        @proxy_port = @proxy.mapped_port(3128)
      end

      def start_wiremock
        keystore_bind = "#{File.join(FIXTURES_DIR, 'keystore.p12')}:/home/wiremock/keystore.p12:ro"
        mappings_bind = "#{File.join(FIXTURES_DIR, 'mappings')}:/home/wiremock/mappings:ro"

        container = Testcontainers::DockerContainer.new('wiremock/wiremock:3.12.1')
                                                   .with_filesystem_binds(keystore_bind)
                                                   .with_filesystem_binds(mappings_bind)
                                                   .with_command(*WIREMOCK_COMMAND)
                                                   .with_exposed_ports(8080, 8443)
                                                   .start
        container.wait_for_http(container_port: 8080, path: '/__admin/mappings', status: 200)
        container
      end

      def start_proxy
        squid_conf = File.join(FIXTURES_DIR, 'squid.conf')
        container = Testcontainers::DockerContainer.new('ubuntu/squid:6.10-24.10_beta')
                                                   .with_filesystem_binds("#{squid_conf}:/etc/squid/squid.conf:ro")
                                                   .with_exposed_ports(3128)
                                                   .start
        container.wait_for_tcp_port(3128)
        container
      end

      def after_all
        @proxy&.stop
        @proxy&.remove
        @wiremock&.stop
        @wiremock&.remove
        @network.remove
        super
      end

      def test_zitadel_exposes_all_service_apis
        expected = Api.constants.map { |const| Api.const_get(const) }
        zitadel = Zitadel.new(Auth::NoAuthAuthenticator.new)
        actual = Zitadel.instance_methods(false).map { |meth| zitadel.public_send(meth).class }

        assert_equal service_api_classes(expected), service_api_classes(actual)
      end

      # The +*ServiceApi+ classes from a list of constants, as a set.
      def service_api_classes(klasses)
        klasses.select { |klass| klass.is_a?(Class) && klass.name.end_with?('ServiceApi') }.to_set
      end

      # Builds a client-credentials SDK client against the given URL with the
      # supplied transport options, then returns the general settings response.
      def general_settings(url, transport_options)
        zitadel = ::Zitadel::Client::Zitadel.with_client_credentials(
          url, 'dummy-client', 'dummy-secret', transport_options: transport_options
        )
        zitadel.settings.get_general_settings({})
      end

      def test_custom_ca_cert
        opts = TransportOptions.builder.ca_cert_path(@ca_cert_path).build

        assert_equal 'https', general_settings("https://#{@host}:#{@https_port}", opts).default_language
      end

      def test_insecure_mode
        opts = TransportOptions.builder.verify_ssl(false).build

        assert_equal 'https', general_settings("https://#{@host}:#{@https_port}", opts).default_language
      end

      def test_default_headers
        opts = TransportOptions.builder.default_headers({ 'X-Custom-Header' => 'test-value' }).build
        response = general_settings("http://#{@host}:#{@http_port}", opts)

        assert_equal 'http', response.default_language
        assert_equal 'test-value', response.default_org_id
      end

      def test_proxy_url
        zitadel = ::Zitadel::Client::Zitadel.with_access_token(
          'http://wiremock:8080',
          'test-token',
          transport_options: TransportOptions.builder.proxy("http://#{@host}:#{@proxy_port}").build
        )

        # Squid resolves the `wiremock` network alias via Docker's embedded DNS,
        # which can briefly be unavailable right after both containers join the
        # network; retry the first proxied call past that warm-up window.
        response = with_proxy_retry { zitadel.settings.get_general_settings({}) }

        assert_equal 'http', response.default_language
      end

      # Retries a block while the proxy reports a transient connectivity error
      # ("Connection reset by peer", "end of file reached"), up to a few times.
      def with_proxy_retry(attempts: 5)
        (1...attempts).each do
          return yield
        rescue Zitadel::Client::ApiError
          sleep 1
        end
        yield
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
