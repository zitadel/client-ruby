# frozen_string_literal: true

module ZitadelClient
  module Auth
    ##
    # A simple authenticator that performs no authentication.
    #
    # This authenticator is useful for cases where no token or credentials are required.
    # It simply returns an empty dictionary for authentication headers.
    #
    class NoAuthAuthenticator < Authenticator
      ##
      # Initializes the NoAuthAuthenticator with a default host.
      #
      # @param host [String] the base URL for the service. Defaults to "http://localhost".
      #
      def initialize(host = 'http://localhost')
        super
      end

      protected

      ##
      # Returns an empty dictionary since no authentication is performed.
      #
      # @return [Hash{String => String}] an empty hash.
      #
      def auth_headers
        {}
      end
    end
  end
end
