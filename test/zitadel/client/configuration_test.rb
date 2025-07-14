# frozen_string_literal: true

# noinspection RubyResolve
require 'test_helper'
require 'minitest/autorun'

module Zitadel
  module Client
    class ConfigurationTest < Minitest::Test
      # OAuth host for testing.
      # noinspection HttpUrlsUsage
      OAUTH_HOST = 'http://zitadel.com'

      # Test user agent getter and setter.
      def test_user_agent
        authenticator = Auth::NoAuthAuthenticator.new(OAUTH_HOST, 'test-token')
        config = Configuration.new(authenticator)

        assert_match(
          %r{^zitadel-client/[\w.-]+ \(lang=ruby; lang_version=[^;]+; os=[^;]+; arch=[^;]+\)$},
          config.user_agent
        )
      end

      # Test getting access token.
      def test_get_access_token
        authenticator = Auth::NoAuthAuthenticator.new(OAUTH_HOST, 'test-token')
        config = Configuration.new(authenticator)

        assert_equal('test-token', config.access_token)
      end

      # Test getting host from authenticator.
      def test_get_host
        authenticator = Auth::NoAuthAuthenticator.new(OAUTH_HOST, 'test-token')
        config = Configuration.new(authenticator)

        assert_equal(OAUTH_HOST, config.host)
      end

      # Test connection timeout.
      def test_get_connect_timeout
        authenticator = Auth::NoAuthAuthenticator.new(OAUTH_HOST, 'test-token')
        config = Configuration.new(authenticator)

        assert_equal(5, config.connect_timeout)
      end

      # Test total timeout.
      def test_get_timeout
        authenticator = Auth::NoAuthAuthenticator.new(OAUTH_HOST, 'test-token')
        config = Configuration.new(authenticator)

        assert_equal(30, config.timeout)
      end
    end
  end
end
