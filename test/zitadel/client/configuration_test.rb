# frozen_string_literal: true

# noinspection RubyResolve
require 'test_helper'
require 'minitest/autorun'

module Zitadel
  module Client
    class ConfigurationTest < Minitest::Test
      ##
      # Test user agent getter and setter
      #
      # @return [void]
      def test_user_agent_getter_and_setter
        config = Configuration.new

        assert_match(
          %r{\Azitadel-client/\d+\.\d+\.\d+([.-][a-zA-Z0-9]+(\.\d+)?)? \(lang=ruby; lang_version=[^;]+; os=[^;]+; arch=[^;]+\)\z},
          config.user_agent
        )
        config.user_agent = 'CustomUserAgent/1.0'

        assert_equal 'CustomUserAgent/1.0', config.user_agent
      end
    end
  end
end
