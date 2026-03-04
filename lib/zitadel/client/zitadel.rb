# frozen_string_literal: true

module Zitadel
  module Client
    # Main entry point for the Zitadel SDK.
    #
    # Initializes and configures the SDK with the provided authentication strategy.
    # Sets up service APIs for interacting with various Zitadel features.
    # noinspection RubyTooManyInstanceVariablesInspection
    class Zitadel # rubocop:disable Metrics/ClassLength
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
        @applications = Api::ApplicationServiceApi.new(client)
        @authorizations = Api::AuthorizationServiceApi.new(client)
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
        @instances = Api::InstanceServiceApi.new(client)
        @internal_permissions = Api::InternalPermissionServiceApi.new(client)
        @beta_features = Api::BetaFeatureServiceApi.new(client)
        @beta_webkeys = Api::BetaWebKeyServiceApi.new(client)
        @beta_actions = Api::BetaActionServiceApi.new(client)
        @projects = Api::ProjectServiceApi.new(client)
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
        # rubocop:disable Metrics/ParameterLists
        def with_access_token(host, access_token, default_headers: {}, ca_cert_path: nil, insecure: false,
                              proxy_url: nil, transport_options: nil)
          resolved = resolve_transport_options(transport_options, default_headers, ca_cert_path, insecure, proxy_url)
          new(Auth::PersonalAccessTokenAuthenticator.new(host, access_token)) do |config|
            apply_transport_options(config, resolved)
          end
        end
        # rubocop:enable Metrics/ParameterLists

        # Initialize the SDK using OAuth2 Client Credentials flow.
        #
        # @param host [String] API URL.
        # @param client_id [String] OAuth2 client identifier.
        # @param client_secret [String] OAuth2 client secret.
        # @return [Zitadel] SDK client with automatic token acquisition & refresh.
        # @see https://zitadel.com/docs/guides/integrate/service-users/client-credentials
        # rubocop:disable Metrics/ParameterLists
        def with_client_credentials(host, client_id, client_secret, default_headers: {}, ca_cert_path: nil,
                                    insecure: false, proxy_url: nil, transport_options: nil)
          resolved = resolve_transport_options(transport_options, default_headers, ca_cert_path, insecure, proxy_url)
          new(
            Auth::ClientCredentialsAuthenticator
              .builder(host, client_id, client_secret, transport_options: resolved)
              .build
          ) do |config|
            apply_transport_options(config, resolved)
          end
        end
        # rubocop:enable Metrics/ParameterLists

        # Initialize the SDK via Private Key JWT assertion.
        #
        # @param host [String] API URL.
        # @param key_file [String] Path to service account JSON/PEM key file.
        # @return [Zitadel] SDK client using JWT assertion for secure, secret-less auth.
        # @see https://zitadel.com/docs/guides/integrate/service-users/private-key-jwt
        # rubocop:disable Metrics/ParameterLists
        def with_private_key(host, key_file, default_headers: {}, ca_cert_path: nil, insecure: false,
                             proxy_url: nil, transport_options: nil)
          resolved = resolve_transport_options(transport_options, default_headers, ca_cert_path, insecure, proxy_url)
          new(Auth::WebTokenAuthenticator.from_json(host, key_file,
                                                    transport_options: resolved)) do |config|
            apply_transport_options(config, resolved)
          end
        end
        # rubocop:enable Metrics/ParameterLists

        # @!endgroup

        private

        def resolve_transport_options(transport_options, default_headers, ca_cert_path, insecure, proxy_url)
          transport_options || TransportOptions.new(default_headers: default_headers,
                                                    ca_cert_path: ca_cert_path,
                                                    insecure: insecure,
                                                    proxy_url: proxy_url)
        end

        def apply_transport_options(config, resolved)
          config.default_headers = resolved.default_headers.dup
          config.ssl_ca_cert = resolved.ca_cert_path if resolved.ca_cert_path
          if resolved.insecure
            config.verify_ssl = false
            config.verify_ssl_host = false
          end
          config.proxy_url = resolved.proxy_url if resolved.proxy_url
        end
      end
    end
  end
end
