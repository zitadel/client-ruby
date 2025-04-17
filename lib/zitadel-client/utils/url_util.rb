# frozen_string_literal: true

require 'uri'

module ZitadelClient
  # Utility module for URL related operations.
  # This is a placeholder for URLUtil, which provides URL utility methods.
  class UrlUtil
    ##
    # Builds the hostname for the provided host.
    #
    # @param host [String] the base URL for the service.
    # @return [String] the fully qualified hostname (defaults to HTTPS if no scheme is provided).
    #
    def self.build_hostname(host)
      uri = URI.parse(host)
      host = "https://#{host}" unless uri.scheme
      host
    end
  end
end
