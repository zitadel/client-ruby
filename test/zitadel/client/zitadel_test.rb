# frozen_string_literal: true

# noinspection RubyResolve
require 'test_helper'
require 'minitest/autorun'

module Zitadel
  module Client
    # This test ensures that the Zitadel SDK class exposes a reader method
    # for every service API class defined in the Zitadel::Client namespace
    # that ends with "ServiceApi".
    #
    # It dynamically collects all service classes and compares them with
    # the classes returned by each public method defined directly on the
    # Zitadel instance.
    # noinspection RbsMissingTypeSignature
    class ZitadelTest < Minitest::Test
      # noinspection RubyArgCount
      def test_zitadel_exposes_all_service_apis
        # Collect all classes under Zitadel::Client that end with "ServiceApi"
        expected = Api.constants
                      .map { |const| Api.const_get(const) }
                      .select { |klass| klass.is_a?(Class) && klass.name.end_with?('ServiceApi') }
                      .to_set

        # Instantiate the Zitadel SDK with a dummy authenticator
        zitadel = Zitadel.new(Auth::NoAuthAuthenticator.new)

        # Collect all instance method return types that are service API classes
        actual = Zitadel.instance_methods(false)
                        .map { |meth| zitadel.public_send(meth).class }
                        .select { |klass| klass.name.end_with?('ServiceApi') }
                        .to_set

        assert_equal expected, actual
      end
    end
  end
end
