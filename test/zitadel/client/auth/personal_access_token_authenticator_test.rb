# frozen_string_literal: true

# Test suite for PersonalAccessTokenAuthenticator.
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

module Zitadel
  module Client
    module Auth
      ##
      # Test suite for the PersonalAccessTokenAuthenticator class.
      #
      # @example Initialization and header retrieval:
      #   auth = PersonalAccessTokenAuthenticator.new("https://api.example.com", "my-secret-token")
      #   auth.get_auth_headers  # => { "Authorization" => "Bearer my-secret-token" }
      #   auth.host              # => "https://api.example.com"
      #
      class PersonalAccessTokenAuthenticatorTest < Minitest::Test
        ##
        # Verifies that the PersonalAccessTokenAuthenticator returns the expected authorization headers and host.
        #
        # @return [void]
        def test_returns_expected_headers_and_host
          auth = Auth::PersonalAccessTokenAuthenticator.new('https://api.example.com',
                                                            'my-secret-token')

          assert_equal({ 'Authorization' => 'Bearer my-secret-token' }, auth.auth_headers)
          assert_equal('https://api.example.com', auth.host)
        end

        ##
        # Verifies that the personal access token is masked in both #inspect and #to_s.
        #
        # @return [void]
        def test_redacts_secret
          secret = 'super-secret-credential-value'
          auth = Auth::PersonalAccessTokenAuthenticator.new('https://api.example.com', secret)

          [auth.inspect, auth.to_s].each do |rendered|
            refute_includes rendered, secret
            assert_includes rendered, '***'
          end
        end

        def test_rejects_bad_arguments
          error = assert_raises(ArgumentError) { Auth::PersonalAccessTokenAuthenticator.new('https://api.example.com', '') }
          assert_instance_of ArgumentError, error
          error = assert_raises(ArgumentError) do
            Auth::PersonalAccessTokenAuthenticator.new('ftp://api.example.com', 'my-secret-token')
          end
          assert_instance_of ArgumentError, error
        end
      end
    end
  end
end
