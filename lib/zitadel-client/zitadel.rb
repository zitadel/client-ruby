module ZitadelClient
  # Main entry point for the Zitadel SDK.
  #
  # Initializes and configures the SDK with the provided authentication strategy.
  # Sets up service APIs for interacting with various Zitadel features.
  class Zitadel
    attr_reader :configuration,
                :features,
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
      @configuration = Configuration.new(authenticator = authenticator)
      yield @configuration if block_given?

      client = ApiClient.new(configuration: @configuration)

      @features = FeatureServiceApi.new(client)
      @idps = IdentityProviderServiceApi.new(client)
      @oidc = OIDCServiceApi.new(client)
      @organizations = OrganizationServiceApi.new(client)
      @sessions = SessionServiceApi.new(client)
      @settings = SettingsServiceApi.new(client)
      @users = UserServiceApi.new(client)
    end
  end
end
