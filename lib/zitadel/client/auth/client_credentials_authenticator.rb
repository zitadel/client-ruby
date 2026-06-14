# frozen_string_literal: true

module Zitadel
  module Client
    module Auth
      # OAuth authenticator implementing the client-credentials flow (RFC 6749 §4.4).
      #
      # Mints a bearer token by POSTing client_id / client_secret to the
      # provider's token endpoint through the SDK's shared transport. See
      # {OAuthAuthenticator} for the caching and HTTP-injection contract.
      class ClientCredentialsAuthenticator < Auth::OAuthAuthenticator
        GRANT_TYPE = 'client_credentials'

        # @param open_id [OpenId] Resolved OpenID configuration for the provider.
        # @param client_id [String] The OAuth client identifier.
        # @param client_secret [String] The OAuth client secret.
        # @param auth_scopes [Set<String>] The scope(s) for the token request.
        def initialize(open_id, client_id, client_secret, auth_scopes)
          super(open_id, client_id, auth_scopes.to_a.join(' '))
          @client_secret = client_secret
        end

        # Returns a new builder for constructing a ClientCredentialsAuthenticator.
        #
        # @param host [String] The OAuth provider's base URL.
        # @param client_id [String] The OAuth client identifier.
        # @param client_secret [String] The OAuth client secret.
        # @param transport_options [TransportOptions, nil] Optional transport options for TLS, proxy, and headers.
        # @return [ClientCredentialsAuthenticatorBuilder]
        def self.builder(host, client_id, client_secret, transport_options: nil)
          ClientCredentialsAuthenticatorBuilder.new(host, client_id, client_secret,
                                                    transport_options: transport_options)
        end

        protected

        # @return [String]
        def grant_type
          GRANT_TYPE
        end

        # @return [Hash{String => String}]
        def access_token_options
          {
            'client_id' => @client_id,
            'client_secret' => @client_secret,
            'scope' => @scope
          }
        end

        # Builder for {ClientCredentialsAuthenticator}.
        class ClientCredentialsAuthenticatorBuilder < OAuthAuthenticatorBuilder
          # @param host [String] The OAuth provider's base URL.
          # @param client_id [String] The OAuth client identifier.
          # @param client_secret [String] The OAuth client secret.
          # @param transport_options [TransportOptions, nil] Optional transport options for TLS, proxy, and headers.
          def initialize(host, client_id, client_secret, transport_options: nil)
            super(host, transport_options: transport_options)
            @client_id = client_id
            @client_secret = client_secret
          end

          # @return [ClientCredentialsAuthenticator]
          def build
            ClientCredentialsAuthenticator.new(open_id, @client_id, @client_secret, auth_scopes)
          end
        end
      end
    end
  end
end
