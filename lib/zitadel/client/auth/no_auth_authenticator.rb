# frozen_string_literal: true

module Zitadel
  module Client
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
        # @param host [String] the base URL for all authentication endpoints.
        # @param token [String] The token to be used for authentication.
        #
        def initialize(host = 'http://localhost', token = 'test-token')
          super(host)
          @token = token
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

        ##
        # Retrieves the authentication token needed for API requests.
        #
        # @return [String] The authentication token.
        #
        def auth_token
          @token
        end
      end
    end
  end
end
