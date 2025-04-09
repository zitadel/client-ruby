# frozen_string_literal: true

require 'time'
require 'set'
require 'openssl'


module ZitadelClient
  # -----------------------------------------------------------------------------
  # WebTokenAuthenticator
  # -----------------------------------------------------------------------------

  # OAuth authenticator implementing the JWT bearer flow.
  #
  # This implementation builds a JWT assertion dynamically in get_grant().
  class WebTokenAuthenticator < OAuthAuthenticator

    # Constructs a WebTokenAuthenticator.
    #
    # @param open_id [OpenId] The OpenId instance with OAuth endpoint information.
    # @param auth_scopes [Set<String>] The scope(s) for the token request.
    # @param jwt_issuer [String] The JWT issuer.
    # @param jwt_subject [String] The JWT subject.
    # @param jwt_audience [String] The JWT audience.
    # @param private_key [String] The private key used to sign the JWT.
    # @param jwt_lifetime [Integer] Lifetime of the JWT in seconds (default 3600 seconds).
    # @param jwt_algorithm [String] The JWT signing algorithm (default "RS256").
    def initialize(open_id, auth_scopes, jwt_issuer, jwt_subject, jwt_audience, private_key, jwt_lifetime = 3600, jwt_algorithm = "RS256")
      # noinspection RubyArgCount,RubyMismatchedArgumentType
      super(open_id, auth_scopes, OAuth2::Client.new("", "", options = {
        site: open_id.get_host_endpoint,
        token_url: open_id.get_token_endpoint
      }))
      @jwt_issuer = jwt_issuer
      @jwt_subject = jwt_subject
      @jwt_audience = jwt_audience
      @private_key = private_key
      @jwt_lifetime = jwt_lifetime
      @jwt_algorithm = jwt_algorithm
    end

    # Overrides the base get_grant to return client credentials grant parameters.
    #
    # @return [OAuth2::AccessToken] A hash containing the grant type.
    def get_grant(client, auth_scopes)
      client.assertion.get_token(
        { iss: @jwt_issuer,
          sub: @jwt_subject,
          aud: @jwt_audience,
          iat: Time.now.utc.to_i,
          exp: (Time.now.utc + @jwt_lifetime).to_i
        },
        {
          algorithm: @jwt_algorithm,
          key: OpenSSL::PKey::RSA.new(@private_key) },
        {
          scope: auth_scopes
        }
      )
    end

    # Returns a builder for constructing a WebTokenAuthenticator.
    #
    # @param host [String] The base URL for the OAuth provider.
    # @param user_id [String] The user identifier (used as both the issuer and subject).
    # @param private_key [String] The private key used to sign the JWT.
    # @return [WebTokenAuthenticatorBuilder] A builder instance.
    def self.builder(host, user_id, private_key)
      WebTokenAuthenticatorBuilder.new(host, user_id, user_id, host, private_key)
    end

    # -----------------------------------------------------------------------------
    # WebTokenAuthenticatorBuilder
    # -----------------------------------------------------------------------------

    # Builder for WebTokenAuthenticator.
    #
    # Provides a fluent API for configuring and constructing a WebTokenAuthenticator instance.
    class WebTokenAuthenticatorBuilder < OAuthAuthenticatorBuilder
      # Initializes the WebTokenAuthenticatorBuilder with required parameters.
      #
      # @param host [String] The base URL for API endpoints.
      # @param jwt_issuer [String] The issuer claim for the JWT.
      # @param jwt_subject [String] The subject claim for the JWT.
      # @param jwt_audience [String] The audience claim for the JWT.
      # @param private_key [String] The PEM-formatted private key used for signing the JWT.
      def initialize(host, jwt_issuer, jwt_subject, jwt_audience, private_key)
        # noinspection RubyArgCount
        super(host)
        @jwt_issuer = jwt_issuer
        @jwt_subject = jwt_subject
        @jwt_audience = jwt_audience
        @private_key = private_key
        @jwt_lifetime = 3600
      end

      # Sets the JWT token lifetime in seconds.
      #
      # @param seconds [Integer] Lifetime of the JWT in seconds.
      # @return [WebTokenAuthenticatorBuilder] The builder instance.
      def token_lifetime_seconds(seconds)
        @jwt_lifetime = seconds
        self
      end

      # Constructs and returns a new WebTokenAuthenticator instance using the configured parameters.
      #
      # @return [WebTokenAuthenticator] A configured instance.
      def build
        WebTokenAuthenticator.new(open_id, auth_scopes, @jwt_issuer, @jwt_subject, @jwt_audience, @private_key, @jwt_lifetime)
      end
    end
  end
end
