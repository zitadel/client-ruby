# frozen_string_literal: true

=begin
Test suite for ZitadelClient::NoAuthAuthenticator.

This test suite verifies that:
- When no host is provided, the authenticator returns empty headers and defaults to "http://localhost" for the host.
- When a custom host is provided, the authenticator returns empty headers and the custom host.

Usage:
  Run this file using:
    bundle exec ruby test/auth/no_auth_authenticator_test.rb
=end

require 'minitest/autorun'
require 'zitadel-client'

module ZitadelClient
  ##
  # Test suite for the NoAuthAuthenticator class.
  #
  # @example When no host is provided, the default host "http://localhost" is used.
  #   auth = ZitadelClient::NoAuthAuthenticator.new
  #   auth.get_auth_headers # => {}
  #   auth.host             # => "http://localhost"
  #
  # @example When a custom host is provided, it is used.
  #   auth = ZitadelClient::NoAuthAuthenticator.new("https://custom-host")
  #   auth.get_auth_headers # => {}
  #   auth.host             # => "https://custom-host"
  # noinspection RbsMissingTypeSignature
  class NoAuthAuthenticatorTest < Minitest::Test
    ##
    # Verifies that the authenticator returns empty headers and the default host when no host is provided.
    #
    # @return [void]
    def test_default_host
      auth = NoAuthAuthenticator.new
      assert_equal({}, auth.get_auth_headers)
      assert_equal("http://localhost", auth.host)
    end

    ##
    # Verifies that the authenticator returns empty headers and the custom host when one is provided.
    #
    # @return [void]
    def test_custom_host
      auth = NoAuthAuthenticator.new("https://custom-host")
      assert_equal({}, auth.get_auth_headers)
      assert_equal("https://custom-host", auth.host)
    end
  end
end
