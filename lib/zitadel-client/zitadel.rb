# frozen_string_literal: true

module ZitadelClient
  # Main entry point for the Zitadel SDK.
  #
  # Initializes and configures the SDK with the provided authentication strategy.
  # Sets up service APIs for interacting with various Zitadel features.
  class Zitadel
    attr_reader :features,
                :idps,
                :oidc,
                :organizations,
                :sessions,
                :settings,
                :users,
                :saml

    # Initialize the Zitadel SDK.
    #
    # @param authenticator [Authenticator] the authentication strategy to use
    # rubocop:disable Metrics/MethodLength
    def initialize(authenticator)
      # noinspection RubyArgCount
      @configuration = Configuration.new(authenticator)
      yield @configuration if block_given?

      client = ApiClient.new(@configuration)

      @features = ZitadelClient::FeatureServiceApi.new(client)
      @idps = ZitadelClient::IdentityProviderServiceApi.new(client)
      @oidc = ZitadelClient::OIDCServiceApi.new(client)
      @organizations = ZitadelClient::OrganizationServiceApi.new(client)
      @sessions = ZitadelClient::SessionServiceApi.new(client)
      @settings = ZitadelClient::SettingsServiceApi.new(client)
      @users = ZitadelClient::UserServiceApi.new(client)
      @saml = ZitadelClient::SAMLServiceApi.new(client)
    end

    # rubocop:enable Metrics/MethodLength

    class << self
      # @!group Authentication Entry Points

      # Initialize the SDK with a Personal Access Token (PAT).
      #
      # @param host [String] API URL (e.g. "https://api.zitadel.example.com").
      # @param access_token [String] Personal Access Token for Bearer authentication.
      # @return [Zitadel] SDK client configured with PAT authentication.
      # @see https://zitadel.com/docs/guides/integrate/service-users/personal-access-token
      def with_access_token(host, access_token)
        new(PersonalAccessTokenAuthenticator.new(host, access_token))
      end

      # Initialize the SDK using OAuth2 Client Credentials flow.
      #
      # @param host [String] API URL.
      # @param client_id [String] OAuth2 client identifier.
      # @param client_secret [String] OAuth2 client secret.
      # @return [Zitadel] SDK client with automatic token acquisition & refresh.
      # @see https://zitadel.com/docs/guides/integrate/service-users/client-credentials
      def with_client_credentials(host, client_id, client_secret)
        new(
          ClientCredentialsAuthenticator
            .builder(host, client_id, client_secret)
            .build
        )
      end

      # Initialize the SDK via Private Key JWT assertion.
      #
      # @param host [String] API URL.
      # @param key_file [String] Path to service account JSON/PEM key file.
      # @return [Zitadel] SDK client using JWT assertion for secure, secret-less auth.
      # @see https://zitadel.com/docs/guides/integrate/service-users/private-key-jwt
      def with_private_key(host, key_file)
        new(WebTokenAuthenticator.from_json(host, key_file))
      end

      # @!endgroup
    end
  end
end
