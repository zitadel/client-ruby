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

##
# Base test class for OAuth authenticators using Testcontainers.
#
# @example
#   class MyAuthenticatorTest < OAuthAuthenticatorTest
#     def test_authenticator_behavior
#       # Access the container's URL via self.class.oauth_host
#     end
#   end
#
class OAuthAuthenticatorTest < Minitest::Test
  class << self
    # The accessible URL for the mock OAuth2 server.
    # @return [String]
    attr_accessor :oauth_host
    # The Docker container instance for the mock OAuth2 server.
    # @return [Testcontainers::Container]
    attr_accessor :mock_oauth2_server
    # Flag to indicate whether the container has been initialized.
    # @return [Boolean]
    attr_accessor :initialized
  end

  ##
  # Sets up the Docker container before any test cases run.
  #
  # Starts a container from the specified image and exposes port 8080.
  # The container's accessible URL is stored in the class variable +oauth_host+.
  #
  # @return [void]
  def self.setup_container
    self.mock_oauth2_server = Testcontainers::Container.new("ghcr.io/navikt/mock-oauth2-server:2.1.10")
                                                       .with_exposed_port(8080)
    # Optionally, configure a wait strategy here if supported.
    mock_oauth2_server.start
    host = mock_oauth2_server.host_ip         # Retrieve the host IP.
    port = mock_oauth2_server.mapped_port(8080)  # Retrieve the mapped port for 8080.
    self.oauth_host = "http://#{host}:#{port}"
    self.initialized = true
  end

  ##
  # Tears down the Docker container after all test cases have run.
  #
  # @return [void]
  def self.teardown_container
    mock_oauth2_server&.stop
  end

  # Initialize the container once before any tests are executed.
  self.setup_container unless self.initialized

  # Register the teardown of the container after the test suite runs.
  Minitest.after_run do
    OAuthAuthenticatorTest.teardown_container
  end
end
