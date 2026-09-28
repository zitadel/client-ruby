# frozen_string_literal: true

module Zitadel
  module Client
    module Auth
      ##
      # Builder for ClientCredentialsAuthenticator.
      class ClientCredentialsAuthenticatorBuilder < OAuthAuthenticatorBuilder
        ##
        # @param host [String] the base URL for the OAuth provider
        # @param client_id [String] the OAuth2 client identifier
        # @param client_secret [String] the OAuth2 client secret
        def initialize(host, client_id, client_secret)
          super(host)
          @client_id = OAuthAuthenticatorBuilder.require_text(client_id, 'Client ID')
          @client_secret = OAuthAuthenticatorBuilder.require_text(client_secret, 'Client secret')
        end

        # @return [ClientCredentialsAuthenticator] the configured authenticator
        def build
          ClientCredentialsAuthenticator.new(open_id, @client_id, @client_secret, scope)
        end
      end
    end
  end
end
