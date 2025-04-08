# frozen_string_literal: true

module ZitadelClient
  # ClientCredentialsAuthenticator implements the client credentials flow.
  class ClientCredentialsAuthenticator < OAuthAuthenticator
    # Constructs a ClientCredentialsAuthenticator using client credentials flow.
    #
    # @param open_id [OpenId] The OpenId instance with OAuth endpoint info.
    # @param client_id [String] The OAuth client identifier.
    # @param client_secret [String] The OAuth client secret.
    # @param auth_scopes [Set<String>] The scope(s) for the token request.
    def initialize(open_id, client_id, client_secret, auth_scopes)
      # noinspection RubyArgCount
      super(open_id, auth_scopes, OAuth2::Client.new(client_id, client_secret, options = {
        site: open_id.get_host_endpoint,
        token_url: open_id.get_token_endpoint
      }))
    end

    # Overrides the base get_grant to return client credentials grant parameters.
    #
    # @return [OAuth2::AccessToken] A hash containing the grant type.
    def get_grant(client, auth_scopes)
      client.client_credentials.get_token({ scope: auth_scopes })
    end

    # Returns a new builder for constructing a ClientCredentialsAuthenticator.
    #
    # @param host [String] The OAuth provider's base URL.
    # @param client_id [String] The OAuth client identifier.
    # @param client_secret [String] The OAuth client secret.
    # @return [ClientCredentialsAuthenticatorBuilder] A builder instance.
    def self.builder(host, client_id, client_secret)
      ClientCredentialsAuthenticatorBuilder.new(host, client_id, client_secret)
    end

    # Builder class for ClientCredentialsAuthenticator.
    class ClientCredentialsAuthenticatorBuilder < OAuthAuthenticatorBuilder
      # Initializes the builder with host, client ID, and client secret.
      #
      # @param host [String] The OAuth provider's base URL.
      # @param client_id [String] The OAuth client identifier.
      # @param client_secret [String] The OAuth client secret.
      def initialize(host, client_id, client_secret)
        # noinspection RubyArgCount
        super(host)
        @client_id = client_id
        @client_secret = client_secret
      end

      # Constructs and returns a ClientCredentialsAuthenticator using the configured parameters.
      #
      # @return [ClientCredentialsAuthenticator] A configured instance.
      def build
        ClientCredentialsAuthenticator.new(open_id, @client_id, @client_secret, super.auth_scopes)
      end
    end
  end
end
