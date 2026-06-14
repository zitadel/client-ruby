# frozen_string_literal: true

module Zitadel
  module Client
    # Main entry point for the Zitadel SDK.
    #
    # Initializes and configures the SDK with the provided authentication
    # strategy and optional {TransportOptions}, then exposes each API group as a
    # short-named property. Mirrors the generated {Client} wiring (shared
    # {ApiClient} + {Configuration} + authenticator injected into every service)
    # while keeping the curated property names and +with_*+ factories.
    # noinspection RubyTooManyInstanceVariablesInspection
    class Zitadel
      # The generated SDK refers to its own namespace with bare, unanchored
      # +Zitadel::Client::...+ constants. Because this facade class is itself
      # named +Zitadel+ and lives inside +Zitadel::Client+, a relative lookup of
      # +Zitadel+ from generated code resolves to this class first, turning
      # +Zitadel::Client::ApiError+ into +Zitadel::Client::Zitadel::Client::ApiError+.
      # Re-exposing the enclosing +Client+ module under this class makes that
      # accidental chain resolve back to the real namespace, so the generated
      # fully-qualified references keep working without anchoring every one with
      # a leading +::+ (see generator bug report).
      Client = ::Zitadel::Client

      attr_reader :features,
                  :idps,
                  :instances,
                  :internal_permissions,
                  :oidc,
                  :organizations,
                  :projects,
                  :saml,
                  :sessions,
                  :settings,
                  :users,
                  :webkeys,
                  :actions,
                  :applications,
                  :authorizations,
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

      # Maps each short-named accessor to the API service class it wires up.
      # Driving the constructor from this table keeps the per-service
      # instantiation declarative and avoids one assignment statement per
      # service in {#initialize}.
      SERVICES = {
        features: Api::FeatureServiceApi,
        idps: Api::IdentityProviderServiceApi,
        oidc: Api::OIDCServiceApi,
        organizations: Api::OrganizationServiceApi,
        saml: Api::SAMLServiceApi,
        sessions: Api::SessionServiceApi,
        settings: Api::SettingsServiceApi,
        users: Api::UserServiceApi,
        webkeys: Api::WebKeyServiceApi,
        actions: Api::ActionServiceApi,
        applications: Api::ApplicationServiceApi,
        authorizations: Api::AuthorizationServiceApi,
        instances: Api::InstanceServiceApi,
        internal_permissions: Api::InternalPermissionServiceApi,
        projects: Api::ProjectServiceApi,
        beta_projects: Api::BetaProjectServiceApi,
        beta_apps: Api::BetaAppServiceApi,
        beta_oidc: Api::BetaOIDCServiceApi,
        beta_users: Api::BetaUserServiceApi,
        beta_organizations: Api::BetaOrganizationServiceApi,
        beta_settings: Api::BetaSettingsServiceApi,
        beta_permissions: Api::BetaInternalPermissionServiceApi,
        beta_authorizations: Api::BetaAuthorizationServiceApi,
        beta_sessions: Api::BetaSessionServiceApi,
        beta_instance: Api::BetaInstanceServiceApi,
        beta_telemetry: Api::BetaTelemetryServiceApi,
        beta_features: Api::BetaFeatureServiceApi,
        beta_webkeys: Api::BetaWebKeyServiceApi,
        beta_actions: Api::BetaActionServiceApi
      }.freeze

      # Initialize the Zitadel SDK.
      #
      # @param authenticator [Auth::Authenticator] the authentication strategy to use.
      # @param transport_options [TransportOptions, nil] HTTP transport configuration.
      def initialize(authenticator, transport_options = nil)
        transport_options ||= TransportOptions.builder.build
        api_client = DefaultApiClient.new(transport_options)
        authenticator.api_client = api_client if authenticator.is_a?(Auth::HttpAwareAuthenticator)

        config = Configuration.builder.base_url(authenticator.host).build

        SERVICES.each do |name, service_class|
          instance_variable_set("@#{name}", service_class.new(api_client, config, authenticator))
        end
      end

      class << self
        # @!group Authentication Entry Points

        # Initialize the SDK with a Personal Access Token (PAT).
        #
        # @param host [String] API URL (e.g. "https://api.zitadel.example.com").
        # @param access_token [String] Personal Access Token for Bearer authentication.
        # @param transport_options [TransportOptions, nil] Optional transport options for TLS, proxy, and headers.
        # @return [Zitadel] Configured Zitadel client instance.
        # @see https://zitadel.com/docs/guides/integrate/service-users/personal-access-token
        def with_access_token(host, access_token, transport_options: nil)
          new(Auth::PersonalAccessTokenAuthenticator.new(host, access_token), transport_options)
        end

        # Initialize the SDK using OAuth2 Client Credentials flow.
        #
        # @param host [String] API URL.
        # @param client_id [String] OAuth2 client identifier.
        # @param client_secret [String] OAuth2 client secret.
        # @param transport_options [TransportOptions, nil] Optional transport options for TLS, proxy, and headers.
        # @return [Zitadel] Configured Zitadel client instance with token auto-refresh.
        # @see https://zitadel.com/docs/guides/integrate/service-users/client-credentials
        def with_client_credentials(host, client_id, client_secret, transport_options: nil)
          new(
            Auth::ClientCredentialsAuthenticator
              .builder(host, client_id, client_secret, transport_options: transport_options)
              .build,
            transport_options
          )
        end

        # Initialize the SDK via Private Key JWT assertion.
        #
        # @param host [String] API URL.
        # @param key_file [String] Path to service account JSON/PEM key file.
        # @param transport_options [TransportOptions, nil] Optional transport options for TLS, proxy, and headers.
        # @return [Zitadel] Configured Zitadel client instance using JWT assertion.
        # @see https://zitadel.com/docs/guides/integrate/service-users/private-key-jwt
        def with_private_key(host, key_file, transport_options: nil)
          new(
            Auth::WebTokenAuthenticator.from_json(host, key_file, transport_options: transport_options),
            transport_options
          )
        end

        # @!endgroup
      end
    end
  end
end
