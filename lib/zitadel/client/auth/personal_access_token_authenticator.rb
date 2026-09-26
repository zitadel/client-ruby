# frozen_string_literal: true

module Zitadel
  module Client
    module Auth
      ##
      # Personal Access Token Authenticator.
      #
      # Uses a static personal access token (PAT) for API authentication. A PAT
      # is a long-lived bearer credential minted out-of-band in the Zitadel
      # console, so no token exchange is required: the token is attached
      # verbatim on every request.
      class PersonalAccessTokenAuthenticator < BaseAuthenticator
        # @return [String] the normalised host endpoint
        attr_reader :host

        ##
        # @param host [String] the base URL for the API endpoints
        # @param token [String] the personal access token
        # @raise [ArgumentError] if the host is not a valid http or https URL or the token is empty
        def initialize(host, token)
          super()
          @host = OpenId.new(host).host_endpoint
          @token = OAuthAuthenticatorBuilder.require_text(token, 'Token')
        end

        # @return [Hash{String => String}] the Authorization header
        def auth_headers
          { 'Authorization' => "Bearer #{@token}" }
        end

        # Redacts the token.
        def inspect
          "#<#{self.class.name} host=#{@host.inspect} token=\"***\">"
        end

        alias to_s inspect
      end
    end
  end
end
