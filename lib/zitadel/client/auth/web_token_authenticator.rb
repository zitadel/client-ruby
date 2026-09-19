# frozen_string_literal: true

require 'json'
require 'jwt'
require 'openssl'

module Zitadel
  module Client
    module Auth
      # JWT-bearer authenticator using the JWT Bearer Grant (RFC 7523).
      #
      # Signs a short-lived JWT assertion with the +jwt+ gem and exchanges it at
      # the provider's token endpoint for an access token. The exchange is sent
      # through the SDK's shared transport; see {OAuthAuthenticator} for the
      # caching and HTTP-injection contract.
      class WebTokenAuthenticator < Auth::OAuthAuthenticator
        GRANT_TYPE = 'urn:ietf:params:oauth:grant-type:jwt-bearer'

        # The signing inputs for the JWT assertion, grouped into a single value
        # so the authenticator and its builder pass them around as one object
        # instead of a long positional parameter list.
        #
        # @!attribute [r] issuer
        #   @return [String] the JWT issuer (iss) claim.
        # @!attribute [r] subject
        #   @return [String] the JWT subject (sub) claim.
        # @!attribute [r] audience
        #   @return [String] the JWT audience (aud) claim.
        # @!attribute [r] private_key
        #   @return [OpenSSL::PKey::RSA] the RSA key used to sign the assertion.
        # @!attribute [r] lifetime
        #   @return [Integer] the assertion lifetime in seconds.
        # @!attribute [r] algorithm
        #   @return [String] the JWT signing algorithm.
        # @!attribute [r] key_id
        #   @return [String, nil] the optional key id (kid) header.
        JwtAssertion = Data.define(:issuer, :subject, :audience, :private_key, :lifetime, :algorithm, :key_id)

        # @param open_id [OpenId] Resolved OpenID configuration for the provider.
        # @param client_id [String] The OAuth2 client identifier.
        # @param auth_scopes [Set<String>] The scope(s) for the token request.
        # @param assertion [JwtAssertion] The JWT signing inputs.
        def initialize(open_id, client_id, auth_scopes, assertion)
          super(open_id, client_id, auth_scopes.to_a.join(' '))
          @assertion = assertion
        end

        # Creates a WebTokenAuthenticator from a service-account JSON file.
        #
        # The JSON file must be formatted as follows:
        #
        #   {
        #     "type": "serviceaccount",
        #     "keyId": "<key-id>",
        #     "key": "<private-key>",
        #     "userId": "<user-id>"
        #   }
        #
        # @param host [String] Base URL for the API endpoints.
        # @param json_path [String] File path to the JSON configuration file.
        # @param transport_options [TransportOptions, nil] Optional transport options for TLS, proxy, and headers.
        # @return [WebTokenAuthenticator]
        # @raise [RuntimeError] If the file cannot be read, the JSON is invalid, or required keys are missing.
        def self.from_json(host, json_path, transport_options: nil)
          config = parse_json_file(json_path)
          raise "Expected a JSON object, got #{config.class}" unless config.is_a?(Hash)

          user_id, private_key, key_id = config.values_at('userId', 'key', 'keyId')
          raise "Missing required keys 'userId', 'keyId' or 'key'" unless user_id && key_id && private_key

          builder(host, user_id, private_key, transport_options: transport_options)
            .key_identifier(key_id).build
        end

        # Reads and parses the service-account JSON file.
        #
        # @param json_path [String] File path to the JSON configuration file.
        # @return [Object] the parsed JSON document.
        # @raise [RuntimeError] If the file cannot be read or the JSON is invalid.
        def self.parse_json_file(json_path)
          JSON.parse(File.read(json_path))
        rescue Errno::ENOENT => e
          raise "Unable to read JSON file at #{json_path}: #{e.message}"
        rescue JSON::ParserError => e
          raise "Invalid JSON in file at #{json_path}: #{e.message}"
        end

        # Returns a builder for constructing a WebTokenAuthenticator.
        #
        # @param host [String] The base URL for the OAuth provider.
        # @param user_id [String] The user identifier (used as both issuer and subject).
        # @param private_key [String] The private key used to sign the JWT.
        # @param transport_options [TransportOptions, nil] Optional transport options for TLS, proxy, and headers.
        # @return [WebTokenAuthenticatorBuilder]
        def self.builder(host, user_id, private_key, transport_options: nil)
          WebTokenAuthenticatorBuilder.new(host, user_id, private_key, transport_options: transport_options)
        end

        protected

        # @return [String]
        def grant_type
          GRANT_TYPE
        end

        # Builds the grant-specific parameters for the JWT-bearer flow, signing a
        # fresh assertion with time-sensitive claims on each token request.
        #
        # @return [Hash{String => String}]
        def access_token_options
          { 'scope' => @scope, 'assertion' => encode_assertion(@assertion) }
        rescue StandardError => e
          raise ZitadelError, "Failed to generate JWT assertion: #{e.message}"
        end

        # Signs a JWT assertion with freshly stamped time claims.
        #
        # @param assertion [JwtAssertion] the signing inputs.
        # @return [String] the signed compact JWT.
        def encode_assertion(assertion)
          now = Time.now.utc
          claims = {
            iss: assertion.issuer, sub: assertion.subject, aud: assertion.audience,
            iat: now.to_i, exp: (now + assertion.lifetime).to_i
          }
          headers = assertion.key_id.nil? ? {} : { 'kid' => assertion.key_id }
          JWT.encode(claims, assertion.private_key, assertion.algorithm, headers)
        end

        # Builder for {WebTokenAuthenticator}.
        class WebTokenAuthenticatorBuilder < OAuthAuthenticatorBuilder
          # The issuer and subject claims both default to the user id; the
          # audience defaults to the host. Callers configure a user id and a
          # host, not three separate claim strings.
          #
          # @param host [String] The base URL for API endpoints (and audience claim).
          # @param user_id [String] The user id used as both issuer and subject claim.
          # @param private_key [String] The PEM-formatted private key used for signing the JWT.
          # @param transport_options [TransportOptions, nil] Optional transport options for TLS, proxy, and headers.
          def initialize(host, user_id, private_key, transport_options: nil)
            super(host, transport_options: transport_options)
            @jwt_issuer = user_id
            @jwt_subject = user_id
            @jwt_audience = host
            @private_key = private_key
            @jwt_lifetime = 3600
            @jwt_algorithm = 'RS256'
            @key_id = nil
          end

          # Sets the JWT token lifetime in seconds.
          # @param seconds [Integer]
          # @return [self]
          def token_lifetime_seconds(seconds)
            @jwt_lifetime = seconds
            self
          end

          # Sets the JWT signing algorithm.
          # @param jwt_algorithm [String]
          # @return [self]
          def jwt_algorithm(jwt_algorithm)
            @jwt_algorithm = jwt_algorithm
            self
          end

          # Sets the optional key id (kid) header.
          # @param key_id [String, nil]
          # @return [self]
          def key_identifier(key_id)
            @key_id = key_id
            self
          end

          # @return [WebTokenAuthenticator]
          def build
            key = @private_key.is_a?(String) ? OpenSSL::PKey::RSA.new(@private_key) : @private_key
            assertion = JwtAssertion.new(
              issuer: @jwt_issuer, subject: @jwt_subject, audience: @jwt_audience,
              private_key: key, lifetime: @jwt_lifetime, algorithm: @jwt_algorithm, key_id: @key_id
            )
            WebTokenAuthenticator.new(open_id, 'zitadel', auth_scopes, assertion)
          end
        end
      end
    end
  end
end
