# frozen_string_literal: true

module Zitadel
  module Client
    module Auth
      # A no-op authenticator that performs no authentication.
      #
      # Useful for testing and unauthenticated endpoints: it has no
      # host-dependent state and never mints a token, so it returns an empty set
      # of auth headers.
      class NoAuthAuthenticator < BaseAuthenticator
        # @return [String]
        attr_reader :host

        # @param host [String] the base URL for the service. Defaults to "http://localhost".
        def initialize(host = 'http://localhost')
          super()
          @host = host
        end

        # @return [Hash{String => String}] an empty hash.
        def auth_headers
          {}
        end
      end
    end
  end
end
