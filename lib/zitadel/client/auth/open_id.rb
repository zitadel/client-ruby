# frozen_string_literal: true

require 'json'
require 'uri'
require 'net/http'
require 'openssl'

module Zitadel
  module Client
    module Auth
      ##
      # OpenId retrieves OpenID Connect configuration from a given host.
      #
      # It builds the well-known configuration URL from the provided hostname,
      # fetches the configuration, and extracts the token endpoint.
      #
      class OpenId
        attr_accessor :token_endpoint, :host_endpoint

        ##
        # Initializes a new OpenId instance.
        #
        # @param hostname [String] the hostname for the OpenID provider.
        # @param transport_options [TransportOptions, nil] Optional transport options for TLS, proxy, and headers.
        # @raise [RuntimeError] if the OpenID configuration cannot be fetched or the token_endpoint is missing.
        #
        # noinspection HttpUrlsUsage
        def initialize(hostname, transport_options: nil)
          transport_options ||= TransportOptions.builder.build
          hostname = "https://#{hostname}" unless hostname.start_with?('http://', 'https://')
          @host_endpoint = hostname

          uri = URI.parse(self.class.build_well_known_url(hostname))
          @token_endpoint = fetch_token_endpoint(uri, transport_options)
        end

        ##
        # Builds the well-known OpenID configuration URL for the given hostname.
        #
        # @param hostname [String] the hostname for the OpenID provider.
        # @return [String] the well-known configuration URL.
        #
        def self.build_well_known_url(hostname)
          URI.join(hostname, '/.well-known/openid-configuration').to_s
        end

        private

        ##
        # Fetches the discovery document and returns its +token_endpoint+.
        #
        # @param uri [URI::Generic] the well-known configuration URL.
        # @param transport_options [TransportOptions] TLS, proxy and header config.
        # @return [String] the discovered token endpoint.
        # @raise [RuntimeError] if the fetch fails or no token_endpoint is present.
        def fetch_token_endpoint(uri, transport_options)
          http = build_http_client(uri, transport_options)
          request = Net::HTTP::Get.new(uri)
          transport_options.default_headers.each { |k, v| request[k] = v }
          response = http.request(request)
          raise "Failed to fetch OpenID configuration: HTTP #{response.code}" unless response.code.to_i == 200

          token_endpoint = JSON.parse(response.body)['token_endpoint']
          raise 'token_endpoint not found in OpenID configuration' unless token_endpoint

          token_endpoint
        end

        ##
        # Builds an +Net::HTTP+ client honouring the proxy and TLS settings.
        #
        # @param uri [URI::Generic] the target URL.
        # @param transport_options [TransportOptions] TLS and proxy config.
        # @return [Net::HTTP] the configured (not yet started) HTTP client.
        # noinspection HttpUrlsUsage
        def build_http_client(uri, transport_options)
          http = new_http(uri, transport_options.proxy)
          http.use_ssl = (uri.scheme == 'https')
          configure_tls(http, transport_options)
          http
        end

        ##
        # Instantiates +Net::HTTP+, routing through the proxy when configured.
        def new_http(uri, proxy)
          return Net::HTTP.new(uri.host.to_s, uri.port) unless proxy

          proxy_uri = URI.parse(proxy)
          Net::HTTP.new(uri.host.to_s, uri.port, proxy_uri.host, proxy_uri.port,
                        proxy_uri.user, proxy_uri.password)
        end

        ##
        # Applies the TLS verification policy (disabled, or peer-verified
        # against an optional custom CA bundle) to the HTTP client.
        def configure_tls(http, transport_options)
          if !transport_options.verify_ssl
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          elsif transport_options.ca_cert_path
            store = OpenSSL::X509::Store.new
            store.set_default_paths
            store.add_file(transport_options.ca_cert_path)
            http.cert_store = store
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          end
        end
      end
    end
  end
end
