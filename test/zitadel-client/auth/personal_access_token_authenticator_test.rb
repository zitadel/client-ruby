# frozen_string_literal: true

# Test suite for ZitadelClient::PersonalAccessTokenAuthenticator.
#
# This suite verifies that:
# - The authenticator returns the correct authorization headers using the provided personal access token.
# - The authenticator exposes the expected host provided during initialization.
#
# Usage:
#   bundle exec ruby test/auth/personal_access_token_authenticator_test.rb

# noinspection RubyResolve
require 'test_helper'
require 'minitest/autorun'

module ZitadelClient
  module Auth
    ##
    # Test suite for the PersonalAccessTokenAuthenticator class.
    #
    # @example Initialization and header retrieval:
    #   auth = ZitadelClient::PersonalAccessTokenAuthenticator.new("https://api.example.com", "my-secret-token")
    #   auth.get_auth_headers  # => { "Authorization" => "Bearer my-secret-token" }
    #   auth.host              # => "https://api.example.com"
    #
    class PersonalAccessTokenAuthenticatorTest < Minitest::Test
      ##
      # Verifies that the PersonalAccessTokenAuthenticator returns the expected authorization headers and host.
      #
      # @return [void]
      def test_returns_expected_headers_and_host
        auth = ZitadelClient::PersonalAccessTokenAuthenticator.new('https://api.example.com',
                                                                   'my-secret-token')

        assert_equal({ 'Authorization' => 'Bearer my-secret-token' }, auth.send(:auth_headers))
        assert_equal('https://api.example.com', auth.send(:host))
      end
    end
  end
end
