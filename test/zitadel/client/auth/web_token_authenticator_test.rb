# frozen_string_literal: true

# Test for WebTokenAuthenticator to verify JWT token refresh functionality using the builder.
# Extends the base OAuthAuthenticatorTest class.
#
# Usage:
#   bundle exec ruby test/auth/web_token_authenticator_test.rb

# noinspection RubyResolve
require 'test_helper'
require 'minitest/autorun'
require 'openssl'
require 'tempfile'
require 'time'
require_relative 'oauth_authenticator_test'

module Zitadel
  module Client
    module Auth
      ##
      # Test suite for the WebTokenAuthenticator class.
      #
      # This suite verifies that the JWT-based authenticator correctly builds tokens,
      # handles refresh logic, and respects configuration values passed to its builder.
      #
      # @example
      #   authenticator = WebTokenAuthenticator.builder(oauth_host, "dummy-client", private_key_pem)
      #                    .token_lifetime_seconds(3600)
      #                    .build
      #   # use authenticator methods to verify JWT token refresh functionality
      #
      class WebTokenAuthenticatorTest < OAuthAuthenticatorTest
        def setup
          key = OpenSSL::PKey::RSA.new(2048).to_pem
          @authenticator = WebTokenAuthenticator
                           .builder(oauth_host, 'dummy-client', key)
                           .token_lifetime_seconds(3600)
                           .build
          inject_api_client(@authenticator)
        end

        def teardown
          @key_files&.each(&:unlink)
          super
        end

        ##
        # @return [void]
        #
        # Ensures the generated access token is present and not empty.
        #
        # This verifies that the authenticator is capable of producing
        # a valid JWT access token under normal conditions.
        def test_access_token_is_not_empty
          token = @authenticator.auth_token

          refute_nil token
          refute_empty token
        end

        ##
        # @return [void]
        #
        # Ensures that `refresh_token` returns a usable, non-expired token.
        #
        # This test confirms that token refresh behavior works correctly
        # and produces a valid, active token that has not yet expired.
        def test_refresh_token_returns_valid_token
          token = @authenticator.refresh_token

          refute_nil token
        end

        ##
        # @return [void]
        #
        # Validates that the Authorization header contains the correct Bearer token.
        #
        # This ensures that consumers of the authenticator can retrieve properly
        # formatted headers for authenticated HTTP requests.
        def test_auth_headers_contains_bearer_token
          token = @authenticator.refresh_token

          expected = { 'Authorization' => "Bearer #{token}" }

          assert_equal expected, @authenticator.auth_headers
        end

        ##
        # @return [void]
        #
        # Verifies that each call to `refresh_token` returns a unique token.
        #
        # This confirms that the authenticator does not cache or reuse tokens
        # and generates fresh credentials on demand.
        def test_refresh_token_produces_unique_tokens
          token1 = @authenticator.refresh_token
          token2 = @authenticator.refresh_token

          refute_equal token1, token2
        end

        ##
        # @return [void]
        #
        # Ensures the authenticator uses the configured OAuth host.
        #
        # This verifies that the `host` parameter passed into the builder
        # is correctly retained and exposed via the `#host` method.
        def test_authenticator_honors_supplied_host
          assert_equal oauth_host, @authenticator.host
        end

        ##
        # @return [void]
        #
        # Verifies that the signing key and cached access token are masked in
        # both #inspect and #to_s.
        def test_redacts_secret
          key = OpenSSL::PKey::RSA.new(2048)
          assertion = WebTokenAuthenticator::JwtAssertion.new(
            issuer: 'z', subject: 'z', audience: 'a', private_key: key, lifetime: 1, algorithm: 'RS256', key_id: nil
          )
          auth = WebTokenAuthenticator.new(OpenId.new('https://example.zitadel.cloud'), 'openid', assertion)
          auth.instance_variable_set(:@access_token, 'super-secret-credential-value')

          rendered = auth.inspect + auth.to_s
          refute_includes rendered, 'super-secret-credential-value'
          refute_includes rendered, key.to_pem
          assert_includes rendered, '***'
        end

        # Writes +content+ to a temporary key file and returns its path.
        def key_file(content)
          file = Tempfile.new(%w[zitadel-key .json])
          file.write(content)
          file.close
          (@key_files ||= []) << file
          file.path.to_s
        end

        def test_loads_key_file
          pem = OpenSSL::PKey::RSA.new(2048).to_pem
          path = key_file({ type: 'serviceaccount', keyId: 'key-1', userId: 'user-1', key: pem }.to_json)

          authenticator = WebTokenAuthenticator.from_json('https://example.zitadel.cloud', path)

          assert_equal 'https://example.zitadel.cloud', authenticator.host
        end

        def test_rejects_bad_key_file
          host = 'https://example.zitadel.cloud'
          missing = File.join(__dir__ || '.', 'absent-zitadel-key.json')
          error = assert_raises(ArgumentError) { WebTokenAuthenticator.from_json(host, missing) }
          assert_instance_of ArgumentError, error

          ['not json', '[]', '{"userId":"user-1","keyId":"key-1"}',
           '{"userId":"user-1","keyId":"key-1","key":"not a pem"}'].each do |content|
            path = key_file(content)
            error = assert_raises(ArgumentError) { WebTokenAuthenticator.from_json(host, path) }
            assert_instance_of ArgumentError, error
          end
        end

        def test_rejects_bad_builder_arguments
          host = 'https://example.zitadel.cloud'
          pem = OpenSSL::PKey::RSA.new(2048).to_pem
          builder = WebTokenAuthenticator.builder(host, 'user-1', pem)

          [
            -> { WebTokenAuthenticator.builder(host, '', pem) },
            -> { WebTokenAuthenticator.builder(host, 'user-1', 'not a pem') },
            -> { builder.jwt_algorithm('HS256') },
            -> { builder.token_lifetime_seconds(0) },
            -> { builder.key_id('') }
          ].each do |action|
            assert_instance_of ArgumentError, assert_raises(ArgumentError) { action.call }
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/AbcSize, Metrics/MethodLength
