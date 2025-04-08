# frozen_string_literal: true

require 'uri'

# Utility module for URL related operations.
# This is a placeholder for URLUtil, which provides URL utility methods.
module URLUtil
  ##
  # Builds the hostname for the provided host.
  #
  # @param host [String] the base URL for the service.
  # @return [String] the fully qualified hostname (defaults to HTTPS if no scheme is provided).
  #
  def self.build_hostname(host)
    uri = URI.parse(host)
    unless uri.scheme
      host = "https://#{host}"
    end
    host
  end
end
