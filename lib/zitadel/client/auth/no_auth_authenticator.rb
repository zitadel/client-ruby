# frozen_string_literal: true

module Zitadel
  module Client
    module Auth
      ##
      # A no-op authenticator that performs no authentication.
      #
      # Useful for testing and unauthenticated endpoints: it never mints a
      # token, so it returns an empty set of auth headers.
      class NoAuthAuthenticator < BaseAuthenticator
        # @return [String] the normalised host endpoint
        attr_reader :host

        ##
        # @param host [String] the base URL for the API endpoints
        # @raise [ArgumentError] if the host is not a valid http or https URL
        def initialize(host = 'http://localhost')
          super()
          @host = OpenId.new(host).host_endpoint
        end

        # @return [Hash] an empty hash, since no authentication is performed
        def auth_headers
          {}
        end
      end
    end
  end
end
