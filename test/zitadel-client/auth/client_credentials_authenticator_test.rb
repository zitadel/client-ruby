# frozen_string_literal: true

=begin
Test for ClientCredentialsAuthenticator to verify token refresh functionality.
Extends the base OAuthAuthenticatorTest class.

This test performs the following:
  - Waits 20 seconds before testing.
  - Builds the ClientCredentialsAuthenticator using a builder pattern.
  - Asserts that an access token is returned and not empty.
  - Asserts that refresh_token returns a token whose headers are correctly formed.
  - Asserts that the token contains a non-nil access token.
  - Asserts that the token expiry is in the future.
  - Asserts that the latest access token equals the token returned by get_auth_token.
  - Asserts that successive refresh_token calls yield different tokens.
  - Asserts that the authenticator returns the expected host.

Usage:
  bundle exec ruby test/auth/client_credentials_authenticator_test.rb
=end

# noinspection RubyResolve
require 'test_helper'
require 'minitest/autorun'
require 'time'
require_relative './oauth_authenticator_test'

module ZitadelClient
  ##
  # Test suite for ClientCredentialsAuthenticator.
  #
  # @example
  #   class MyTest < ClientCredentialsAuthenticatorTest
  #     def test_refresh_token
  #       # test functionality here
  #     end
  #   end
  #
  class ClientCredentialsAuthenticatorTest < ZitadelClient::OAuthAuthenticatorTest
    ##
    # Verifies token refresh functionality of ClientCredentialsAuthenticator.
    #
    # @return [void]
    def test_refresh_token
      authenticator = ClientCredentialsAuthenticator.builder(self.class.oauth_host, "dummy-client", "dummy-secret")
                                                    .scopes("openid", "foo")
                                                    .build

      token_str = authenticator.send(:get_auth_token)
      refute_nil token_str, "Access token should not be nil"
      refute_empty token_str, "Access token should not be empty"

      token = authenticator.send(:refresh_token)
      expected_headers = { "Authorization" => "Bearer " + token.token }
      assert_equal expected_headers, authenticator.send(:get_auth_headers)

      refute_nil token.token, "Access token should not be null"

      refute token.expired?, "Token should not be expired"

      assert_equal token.token, authenticator.send(:get_auth_token)
      assert_equal self.class.oauth_host, authenticator.send(:host)

      token1 = authenticator.send(:refresh_token).token
      token2 = authenticator.send(:refresh_token).token
      refute_equal token1, token2, "Two refreshToken calls should produce different tokens"
    end
  end
end
