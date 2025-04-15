# frozen_string_literal: true

=begin
Base test class for OAuth authenticators.

This class starts a Docker container running the mock OAuth2 server
(ghcr.io/navikt/mock-oauth2-server:2.1.10) before any tests run and stops it after all tests.
It sets the class variable `oauth_host` to the container’s accessible URL.

The container is expected to expose port 8080 and, if supported, may be configured to wait
for an HTTP response from the "/" endpoint with a status code of 405 (using a wait strategy).
=end

# noinspection RubyResolve
require 'test_helper'
require 'minitest/autorun'
require 'testcontainers'

module ZitadelClient
  class OAuthAuthenticatorTest < Minitest::Test
    # noinspection RbsMissingTypeSignature
    class << self
      attr_accessor :oauth_host, :mock_server, :initialized

      def inherited(subclass)
        super
        subclass.setup_container unless subclass.initialized
        Minitest.after_run { subclass.teardown_container }
      end
    end

    def self.setup_container
      self.mock_server = Testcontainers::DockerContainer.new("ghcr.io/navikt/mock-oauth2-server:2.1.10")
                                                        .with_exposed_port(8080)
      mock_server.start.wait_for_http(container_port: 8080, status: 405)

      # noinspection HttpUrlsUsage
      self.oauth_host = "http://#{mock_server.host}:#{mock_server.mapped_port(8080)}"
      self.initialized = true
    end

    def self.teardown_container
      mock_server&.stop
    end
  end
end
