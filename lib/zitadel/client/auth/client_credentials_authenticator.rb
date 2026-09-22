# frozen_string_literal: true

module Zitadel
  module Client
    module Auth
      ##
      # OAuth authenticator implementing the client-credentials flow (RFC 6749 §4.4).
      #
      # Mints a bearer token by POSTing client_id / client_secret to the
      # provider's token endpoint through the SDK's shared transport. See
      # OAuthAuthenticator for the caching and HTTP-injection contract.
      class ClientCredentialsAuthenticator < Auth::OAuthAuthenticator
        GRANT_TYPE = 'client_credentials'

        # @return [String] the OAuth2 client identifier
        attr_reader :client_id

        ##
        # @param open_id [OpenId] the OpenID discovery helper for the target host
        # @param client_id [String] the OAuth2 client identifier
        # @param client_secret [String] the OAuth2 client secret
        # @param scope [String] the space-delimited scope string for the token request
        def initialize(open_id, client_id, client_secret, scope)
          super(open_id, scope)
          @client_id = client_id
          @client_secret = client_secret
        end

        ##
        # Returns a builder for a ClientCredentialsAuthenticator.
        #
        # @param host [String] the base URL for the OAuth provider
        # @param client_id [String] the OAuth2 client identifier
        # @param client_secret [String] the OAuth2 client secret
        # @return [ClientCredentialsAuthenticatorBuilder] the builder
        # @raise [ArgumentError] if the host is not a valid http or https URL, or
        #   the client identifier or secret is empty
        def self.builder(host, client_id, client_secret)
          ClientCredentialsAuthenticatorBuilder.new(host, client_id, client_secret)
        end

        # Redacts the client secret and the cached access token.
        def inspect
          "#<#{self.class.name} host=#{host.inspect} client_id=#{@client_id.inspect} client_secret=\"***\" " \
            "scope=#{@scope.inspect} access_token=#{masked_token.inspect}>"
        end

        alias to_s inspect

        protected

        def grant_type
          GRANT_TYPE
        end

        def token_request_params
          { 'client_id' => @client_id, 'client_secret' => @client_secret }
        end
      end
    end
  end
end
