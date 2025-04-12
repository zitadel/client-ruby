require "test_helper"
require "minitest/autorun"

module ZitadelClient
  # This test ensures that the Zitadel SDK class exposes a reader method
  # for every service API class defined in the ZitadelClient namespace
  # that ends with "ServiceApi".
  #
  # It dynamically collects all service classes and compares them with
  # the classes returned by each public method defined directly on the
  # Zitadel instance.
  # noinspection RbsMissingTypeSignature
  class ZitadelClientTest < Minitest::Test
    def test_zitadel_exposes_all_service_apis
      # Collect all classes under ZitadelClient that end with "ServiceApi"
      expected = ZitadelClient.constants
                              .map { |const| ZitadelClient.const_get(const) }
                              .select { |klass| klass.is_a?(Class) && klass.name.end_with?("ServiceApi") }
                              .to_set

      # Instantiate the Zitadel SDK with a dummy authenticator
      zitadel = Zitadel.new(NoAuthAuthenticator.new)

      # Collect all instance method return types that are service API classes
      actual = Zitadel.instance_methods(false)
                      .map { |meth| zitadel.public_send(meth).class }
                      .select { |klass| klass.name.end_with?("ServiceApi") }
                      .to_set

      assert_equal expected, actual
    end
  end
end
