# frozen_string_literal: true

module Zitadel
  module Client
    # Main entry point for the Zitadel SDK.
    #
    # Initializes and configures the SDK with the provided authentication strategy.
    # Sets up service APIs for interacting with various Zitadel features.
    # noinspection RubyTooManyInstanceVariablesInspection
    class Zitadel
      attr_reader :features,
                  :idps,
                  :oidc,
                  :organizations,
                  :saml,
                  :sessions,
                  :settings,
                  :users,
                  :webkeys,
                  :actions,
                  # Beta services
                  :beta_projects,
                  :beta_apps,
                  :beta_oidc,
                  :beta_users,
                  :beta_organizations,
                  :beta_settings,
                  :beta_permissions,
                  :beta_authorizations,
                  :beta_sessions,
                  :beta_instance,
                  :beta_telemetry,
                  :beta_features,
                  :beta_webkeys,
                  :beta_actions

      # Initialize the Zitadel SDK.
      #
      # @param authenticator [Authenticator] the authentication strategy to use
      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def initialize(authenticator)
        # noinspection RubyArgCount
        @configuration = Configuration.new(authenticator)
        yield @configuration if block_given?

        client = ApiClient.new(@configuration)

        @features = Api::FeatureServiceApi.new(client)
        @idps = Api::IdentityProviderServiceApi.new(client)
        @oidc = Api::OIDCServiceApi.new(client)
        @organizations = Api::OrganizationServiceApi.new(client)
        @saml = Api::SAMLServiceApi.new(client)
        @sessions = Api::SessionServiceApi.new(client)
        @settings = Api::SettingsServiceApi.new(client)
        @users = Api::UserServiceApi.new(client)
        @webkeys = Api::WebKeyServiceApi.new(client)
        @actions = Api::ActionServiceApi.new(client)
        @beta_projects = Api::BetaProjectServiceApi.new(client)
        @beta_apps = Api::BetaAppServiceApi.new(client)
        @beta_oidc = Api::BetaOIDCServiceApi.new(client)
        @beta_users = Api::BetaUserServiceApi.new(client)
        @beta_organizations = Api::BetaOrganizationServiceApi.new(client)
        @beta_settings = Api::BetaSettingsServiceApi.new(client)
        @beta_permissions = Api::BetaInternalPermissionServiceApi.new(client)
        @beta_authorizations = Api::BetaAuthorizationServiceApi.new(client)
        @beta_sessions = Api::BetaSessionServiceApi.new(client)
        @beta_instance = Api::BetaInstanceServiceApi.new(client)
        @beta_telemetry = Api::BetaTelemetryServiceApi.new(client)
        @beta_features = Api::BetaFeatureServiceApi.new(client)
        @beta_webkeys = Api::BetaWebKeyServiceApi.new(client)
        @beta_actions = Api::BetaActionServiceApi.new(client)
      end

      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      class << self
        # @!group Authentication Entry Points

        # Initialize the SDK with a Personal Access Token (PAT).
        #
        # @param host [String] API URL (e.g. "https://api.zitadel.example.com").
        # @param access_token [String] Personal Access Token for Bearer authentication.
        # @return [Zitadel] SDK client configured with PAT authentication.
        # @see https://zitadel.com/docs/guides/integrate/service-users/personal-access-token
        def with_access_token(host, access_token)
          new(Auth::PersonalAccessTokenAuthenticator.new(host, access_token))
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
            Auth::ClientCredentialsAuthenticator
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
          new(Auth::WebTokenAuthenticator.from_json(host, key_file))
        end

        # @!endgroup
      end
    end
  end
end
