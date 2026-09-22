# frozen_string_literal: true

require 'json'
require 'jwt'
require 'openssl'

module Zitadel
  module Client
    module Auth
      ##
      # JWT-bearer authenticator using the JWT Bearer Grant (RFC 7523).
      #
      # Signs a short-lived JWT assertion and exchanges it at the provider's
      # token endpoint for an access token. The exchange is sent through the
      # SDK's shared transport; see OAuthAuthenticator for the caching and
      # HTTP-injection contract.
      class WebTokenAuthenticator < Auth::OAuthAuthenticator
        GRANT_TYPE = 'urn:ietf:params:oauth:grant-type:jwt-bearer'

        # The signing algorithms the builder accepts.
        ALGORITHMS = %w[RS256 RS384 RS512].freeze

        # The claims and signing material of the JWT assertion.
        JwtAssertion = Data.define(:issuer, :subject, :audience, :private_key, :lifetime, :algorithm, :key_id)

        ##
        # @param open_id [OpenId] the OpenID discovery helper for the target host
        # @param scope [String] the space-delimited scope string for the token request
        # @param assertion [JwtAssertion] the assertion claims and signing key
        def initialize(open_id, scope, assertion)
          super(open_id, scope)
          @assertion = assertion
        end

        ##
        # Creates a WebTokenAuthenticator from a Zitadel service-account key file.
        #
        # Expected JSON format:
        #   {
        #     "type": "serviceaccount",
        #     "keyId": "<key-id>",
        #     "key": "<private-key>",
        #     "userId": "<user-id>"
        #   }
        #
        # @param host [String] the base URL for the API endpoints
        # @param json_path [String] the path to the key file
        # @return [WebTokenAuthenticator] the configured authenticator
        # @raise [ArgumentError] if the file cannot be read, is not a JSON object,
        #   lacks the string fields userId, keyId and key, or holds an invalid key
        def self.from_json(host, json_path)
          config = read_key_file(json_path)
          user_id, key_id, private_key = config.values_at('userId', 'keyId', 'key')
          unless [user_id, key_id, private_key].all?(String)
            raise ArgumentError, "The key file at #{json_path} must contain the string fields userId, keyId and key"
          end

          builder(host, user_id, private_key).key_id(key_id).build
        end

        # @return [Hash] the parsed key file
        # @raise [ArgumentError] if the file cannot be read or is not a JSON object
        def self.read_key_file(json_path)
          config = parse_json(read_file(json_path))
          raise ArgumentError, "The key file at #{json_path} is not a JSON object" unless config.is_a?(Hash)

          config
        end

        # @return [String] the file content
        # @raise [ArgumentError] if the file cannot be read
        def self.read_file(json_path)
          File.read(json_path)
        rescue SystemCallError, IOError => e
          raise ArgumentError, "Unable to read the key file at #{json_path}", cause: e
        end

        # @return [Object, nil] the parsed JSON, or nil when it does not parse
        def self.parse_json(content)
          JSON.parse(content)
        rescue JSON::ParserError
          nil
        end

        private_class_method :read_key_file, :read_file, :parse_json

        ##
        # Returns a builder for a WebTokenAuthenticator.
        #
        # @param host [String] the base URL for the OAuth provider
        # @param user_id [String] the user ID, used as both the issuer and the subject
        # @param private_key [String] the PEM-encoded RSA private key used to sign the JWT
        # @return [WebTokenAuthenticatorBuilder] the builder
        # @raise [ArgumentError] if the host is not a valid http or https URL, the
        #   user ID is empty, or the key is not an RSA private key
        def self.builder(host, user_id, private_key)
          WebTokenAuthenticatorBuilder.new(host, user_id, private_key)
        end

        protected

        def grant_type
          GRANT_TYPE
        end

        def token_request_params
          { 'assertion' => encode_assertion(@assertion) }
        end

        private

        def encode_assertion(assertion)
          now = Time.now.utc
          claims = {
            iss: assertion.issuer, sub: assertion.subject, aud: assertion.audience,
            iat: now.to_i, exp: (now + assertion.lifetime).to_i
          }
          headers = assertion.key_id.nil? ? {} : { 'kid' => assertion.key_id }
          JWT.encode(claims, assertion.private_key, assertion.algorithm, headers)
        rescue JWT::EncodeError, OpenSSL::PKey::PKeyError => e
          raise 'Unable to sign the JWT assertion', cause: e
        end
      end
    end
  end
end
