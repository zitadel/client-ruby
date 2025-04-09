# frozen_string_literal: true

=begin
Base test class for OAuth authenticators.

This class starts a Docker container running the mock OAuth2 server
(ghcr.io/navikt/mock-oauth2-server:2.1.10) before any tests run and stops it after all tests.
It sets the class variable `oauth_host` to the container’s accessible URL.

The container is expected to expose port 8080 and, if supported, may be configured to wait
for an HTTP response from the "/" endpoint with a status code of 405 (using a wait strategy).
=end

require 'minitest/autorun'
require 'testcontainers'

module ZitadelClient
  class OAuthAuthenticatorTest < Minitest::Test
    class << self
      attr_accessor :oauth_host, :mock_oauth2_server, :initialized

      def inherited(subclass)
        super
        # Start the container for the subclass if it hasn’t been initialized.
        subclass.setup_container unless subclass.initialized
        # Ensure the container is stopped after the test run for this subclass.
        Minitest.after_run { subclass.teardown_container }
      end
    end

    def self.setup_container
      self.mock_oauth2_server = Testcontainers::DockerContainer.new("ghcr.io/navikt/mock-oauth2-server:2.1.10")
                                                               .with_exposed_port(8080)
      # Optionally, add a wait strategy here if supported.
      mock_oauth2_server.start
      host = mock_oauth2_server.host  # Retrieve the host IP.
      port = mock_oauth2_server.mapped_port(8080)  # Retrieve the mapped port.
      self.oauth_host = "http://#{host}:#{port}"
      self.initialized = true
    end

    def self.teardown_container
      mock_oauth2_server&.stop
    end
  end
end
