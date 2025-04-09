# frozen_string_literal: true

=begin
Test for WebTokenAuthenticator to verify JWT token refresh functionality using the builder.
Extends the base OAuthAuthenticatorTest class.

Usage:
  bundle exec ruby test/auth/web_token_authenticator_test.rb
=end

require 'minitest/autorun'
require 'openssl'
require 'time'
require 'zitadel-client'

module ZitadelClient
  ##
  # Test suite for the WebTokenAuthenticator class.
  #
  # @example
  #   authenticator = WebTokenAuthenticator.builder(oauth_host, "dummy-client", private_key_pem)
  #                    .token_lifetime_seconds(3600)
  #                    .build
  #   # use authenticator methods to verify JWT token refresh functionality
  #
  class WebTokenAuthenticatorTest < OAuthAuthenticatorTest
    ##
    # Verifies that WebTokenAuthenticator correctly refreshes the JWT token using the builder.
    #
    # @return [void]
    def test_refresh_token_using_builder
      sleep 20

      # Generate an RSA key and convert it to PEM format.
      rsa_key = OpenSSL::PKey::RSA.new(2048)
      private_key_pem = rsa_key.to_pem

      authenticator = WebTokenAuthenticator.builder(self.class.oauth_host, "dummy-client", private_key_pem)
                                           .token_lifetime_seconds(3600)
                                           .build

      token_str = authenticator.get_auth_token
      refute_nil token_str, "Access token should not be empty"
      refute_empty token_str, "Access token should not be empty"

      token = authenticator.refresh_token
      expected_headers = { "Authorization" => "Bearer " + token.token }
      assert_equal expected_headers, authenticator.get_auth_headers

      refute_nil token.token, "Access token should not be null"

      refute token.expired?, "Token should not be expired"

      assert_equal token.token, authenticator.get_auth_token
      assert_equal self.class.oauth_host, authenticator.host

      token1 = authenticator.refresh_token.token
      token2 = authenticator.refresh_token.token
      refute_equal token1, token2, "Two refreshToken calls should produce different tokens"
    end
  end
end
