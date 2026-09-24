# frozen_string_literal: true

require 'openssl'

module Zitadel
  module Client
    module Auth
      ##
      # Builder for WebTokenAuthenticator.
      class WebTokenAuthenticatorBuilder < OAuthAuthenticatorBuilder
        ##
        # @param host [String] the base URL for the OAuth provider
        # @param user_id [String] the user ID, used as both the issuer and the subject
        # @param private_key [String] the PEM-encoded RSA private key used to sign the JWT
        def initialize(host, user_id, private_key)
          super(host)
          @user_id = OAuthAuthenticatorBuilder.require_text(user_id, 'User ID')
          @private_key = load_private_key(private_key)
          @lifetime = 3600
          @algorithm = 'RS256'
          @key_id = nil
        end

        ##
        # Sets the JWT assertion lifetime in seconds.
        #
        # @param seconds [Integer] the lifetime; must be positive
        # @return [self] the builder
        # @raise [ArgumentError] if the lifetime is not positive
        def token_lifetime_seconds(seconds)
          raise ArgumentError, 'Token lifetime must be a positive number of seconds.' unless seconds.is_a?(Integer) && seconds.positive?

          @lifetime = seconds
          self
        end

        ##
        # Sets the JWT signing algorithm.
        #
        # @param jwt_algorithm [String] one of RS256, RS384 or RS512
        # @return [self] the builder
        # @raise [ArgumentError] if the algorithm is not supported
        def jwt_algorithm(jwt_algorithm)
          raise ArgumentError, "Unsupported JWT algorithm '#{jwt_algorithm}'; use RS256, RS384 or RS512." unless WebTokenAuthenticator::ALGORITHMS.include?(jwt_algorithm)

          @algorithm = jwt_algorithm
          self
        end

        ##
        # Sets the key ID sent as the +kid+ header of the assertion.
        #
        # @param key_id [String] the key identifier
        # @return [self] the builder
        # @raise [ArgumentError] if the key ID is empty
        def key_id(key_id)
          @key_id = OAuthAuthenticatorBuilder.require_text(key_id, 'Key ID')
          self
        end

        # @return [WebTokenAuthenticator] the configured authenticator
        def build
          assertion = WebTokenAuthenticator::JwtAssertion.new(
            issuer: @user_id, subject: @user_id, audience: open_id.host_endpoint,
            private_key: @private_key, lifetime: @lifetime, algorithm: @algorithm, key_id: @key_id
          )
          WebTokenAuthenticator.new(open_id, scope, assertion)
        end

        private

        # @return [OpenSSL::PKey::RSA] the parsed key
        # @raise [ArgumentError] if the PEM is not an RSA private key
        def load_private_key(pem)
          key = OpenSSL::PKey::RSA.new(pem.to_s)
          raise ArgumentError, 'Private key is not a valid RSA private key.' unless key.private?

          key
        rescue OpenSSL::PKey::PKeyError => e
          raise ArgumentError, 'Private key is not a valid RSA private key.', cause: e
        end
      end
    end
  end
end
