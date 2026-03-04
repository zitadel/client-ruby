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
        # @raise [RuntimeError] if the OpenID configuration cannot be fetched or the token_endpoint is missing.
        #
        # noinspection HttpUrlsUsage
        # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        def initialize(hostname, transport_options: nil)
          transport_options ||= TransportOptions.defaults
          hostname = "https://#{hostname}" unless hostname.start_with?('http://', 'https://')
          @host_endpoint = hostname
          well_known_url = self.class.build_well_known_url(hostname)

          uri = URI.parse(well_known_url)
          http = if transport_options.proxy_url
                   proxy_uri = URI.parse(transport_options.proxy_url)
                   Net::HTTP.new(uri.host.to_s, uri.port, proxy_uri.host, proxy_uri.port)
                 else
                   Net::HTTP.new(uri.host.to_s, uri.port)
                 end
          http.use_ssl = (uri.scheme == 'https')
          if transport_options.insecure
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          elsif transport_options.ca_cert_path
            http.ca_file = transport_options.ca_cert_path
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER
            http.verify_hostname = false
          end
          request = Net::HTTP::Get.new(uri)
          transport_options.default_headers.each { |k, v| request[k] = v }
          response = http.request(request)
          raise "Failed to fetch OpenID configuration: HTTP #{response.code}" unless response.code.to_i == 200

          config = JSON.parse(response.body)
          token_endpoint = config['token_endpoint']
          raise 'token_endpoint not found in OpenID configuration' unless token_endpoint

          @token_endpoint = token_endpoint
        end
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

        ##
        # Builds the well-known OpenID configuration URL for the given hostname.
        #
        # @param hostname [String] the hostname for the OpenID provider.
        # @return [String] the well-known configuration URL.
        #
        def self.build_well_known_url(hostname)
          URI.join(hostname, '/.well-known/openid-configuration').to_s
        end
      end
    end
  end
end
