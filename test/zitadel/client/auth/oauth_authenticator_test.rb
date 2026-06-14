# frozen_string_literal: true

# Base test class for OAuth authenticators.
#
# This class starts a Docker container running the mock OAuth2 server
# (ghcr.io/navikt/mock-oauth2-server:2.1.10) before any tests run and stops it after all tests.
# It sets the class variable `oauth_host` to the container’s accessible URL.
#
# The container is expected to expose port 8080 and, if supported, may be configured to wait
# for an HTTP response from the "/" endpoint with a status code of 405 (using a wait strategy).

# noinspection RubyResolve
require 'test_helper'
require 'minitest/autorun'
require 'minitest/hooks/test'
require 'testcontainers'

module Zitadel
  module Client
    module Auth
      class OAuthAuthenticatorTest < Minitest::Test
        # noinspection RbsMissingTypeSignature
        include Minitest::Hooks

        def before_all
          super
          @mock_server = Testcontainers::DockerContainer.new('ghcr.io/navikt/mock-oauth2-server:2.1.10')
                                                        .with_exposed_port(8080)
                                                        .start
          @mock_server.wait_for_http(container_port: 8080, status: 405)
          # noinspection HttpUrlsUsage
          @oauth_host = "http://#{@mock_server.host}:#{@mock_server.mapped_port(8080)}"
        end

        def after_all
          @mock_server.stop
          super
        end

        # Helper for subclasses to access the OAuth host.
        attr_reader :oauth_host

        # Injects a real SDK transport into the authenticator, mirroring what
        # Zitadel::Client::Client does for HttpAwareAuthenticator instances.
        #
        # The bespoke OAuth authenticators require the shared ApiClient before
        # they can perform token exchange against the mock OAuth2 server.
        #
        # @param authenticator [HttpAwareAuthenticator]
        # @return [HttpAwareAuthenticator] the same authenticator, for chaining
        def inject_api_client(authenticator)
          authenticator.api_client =
            Zitadel::Client::DefaultApiClient.new(Zitadel::Client::TransportOptions.builder.build)
          authenticator
        end
      end
    end
  end
end
