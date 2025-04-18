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
require 'time'
require_relative 'oauth_authenticator_test'

module ZitadelClient
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
    end

    ##
    # @return [void]
    #
    # Ensures the generated access token is present and not empty.
    #
    # This verifies that the authenticator is capable of producing
    # a valid JWT access token under normal conditions.
    def test_access_token_is_not_empty
      token = @authenticator.send(:auth_token)

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
      token = @authenticator.send(:refresh_token)

      refute_nil token.token
      refute_predicate token, :expired?
    end

    ##
    # @return [void]
    #
    # Validates that the Authorization header contains the correct Bearer token.
    #
    # This ensures that consumers of the authenticator can retrieve properly
    # formatted headers for authenticated HTTP requests.
    def test_auth_headers_contains_bearer_token
      token = @authenticator.send(:refresh_token)

      expected = { 'Authorization' => "Bearer #{token.token}" }

      assert_equal expected, @authenticator.send(:auth_headers)
    end

    ##
    # @return [void]
    #
    # Verifies that each call to `refresh_token` returns a unique token.
    #
    # This confirms that the authenticator does not cache or reuse tokens
    # and generates fresh credentials on demand.
    def test_refresh_token_produces_unique_tokens
      token1 = @authenticator.send(:refresh_token).token
      token2 = @authenticator.send(:refresh_token).token

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
      assert_equal oauth_host, @authenticator.send(:host)
    end
  end
end
