# frozen_string_literal: true

# Test for ClientCredentialsAuthenticator to verify token refresh functionality.
# Extends the base OAuthAuthenticatorTest class.
#
# Usage:
#   bundle exec ruby test/auth/client_credentials_authenticator_test.rb

# noinspection RubyResolve
require 'test_helper'
require 'minitest/autorun'
require 'time'
require_relative 'oauth_authenticator_test'

module ZitadelClient
  ##
  # Test suite for the ClientCredentialsAuthenticator class.
  #
  # This suite verifies that the authenticator correctly builds tokens,
  # handles refresh logic, and respects configuration values passed to its builder.
  #
  # @example
  #   authenticator = ClientCredentialsAuthenticator.builder(oauth_host, "client-id", "secret")
  #                    .scopes("openid", "foo")
  #                    .build
  #   # use authenticator methods to verify token refresh functionality
  #
  class ClientCredentialsAuthenticatorTest < OAuthAuthenticatorTest
    def setup
      @authenticator = ClientCredentialsAuthenticator
                       .builder(oauth_host, 'dummy-client', 'dummy-secret')
                       .scopes('openid', 'foo')
                       .build
    end

    ##
    # @return [void]
    #
    # Ensures the generated access token is present and not empty.
    #
    # This verifies that the authenticator is capable of producing
    # a valid access token under normal conditions.
    def test_access_token_is_not_empty
      token = @authenticator.send(:auth_token)

      refute_nil token
      refute_empty token
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
    # Asserts that the latest access token matches the token returned by `auth_token`.
    #
    # This verifies that the authenticator memoizes or reuses the token internally as expected.
    def test_auth_token_matches_refreshed_token
      token = @authenticator.send(:refresh_token)

      assert_equal token.token, @authenticator.send(:auth_token)
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
  end
end
