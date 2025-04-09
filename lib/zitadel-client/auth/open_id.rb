# frozen_string_literal: true

require 'json'
require 'uri'
require 'net/http'

module ZitadelClient
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
    def initialize(hostname)
      unless hostname.start_with?('http://', 'https://')
        hostname = "https://#{hostname}"
      end
      @host_endpoint = hostname
      well_known_url = self.class.build_well_known_url(hostname)

      uri = URI.parse(well_known_url)
      response = Net::HTTP.get_response(uri)
      unless response.code.to_i == 200
        raise "Failed to fetch OpenID configuration: HTTP #{response.code}"
      end

      config = JSON.parse(response.body)
      token_endpoint = config['token_endpoint']
      unless token_endpoint
        raise 'token_endpoint not found in OpenID configuration'
      end
      @token_endpoint = token_endpoint
    end

    private

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
