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
                :users

    # Initialize the Zitadel SDK.
    #
    # @param authenticator [Authenticator] the authentication strategy to use
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
    end

    class << self
      # Initialize the SDK using a personal access token
      #
      # @param host [String] the Zitadel instance URL
      # @param access_token [String] the personal access token
      # @return [Zitadel] configured SDK instance
      def with_access_token(host, access_token)
        new(PersonalAccessTokenAuthenticator.new(host, access_token))
      end

      # Initialize the SDK using OAuth2 client credentials
      #
      # @param host [String] the Zitadel instance URL
      # @param client_id [String] OAuth2 client identifier
      # @param client_secret [String] OAuth2 client secret
      # @return [Zitadel] configured SDK instance
      def with_client_credentials(host, client_id, client_secret)
        new(
          ClientCredentialsAuthenticator
            .builder(host, client_id, client_secret)
            .build
        )
      end

      # Initialize the SDK using a service account private key
      #
      # @param host [String] the Zitadel instance URL
      # @param key_file [String] path to the private key file (PEM)
      # @return [Zitadel] configured SDK instance
      def with_private_key(host, key_file)
        new(WebTokenAuthenticator.from_json(host, key_file).build)
      end
    end
  end
end
