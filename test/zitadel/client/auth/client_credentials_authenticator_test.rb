# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength, Metrics/AbcSize, Metrics/MethodLength

# Test for ClientCredentialsAuthenticator to verify token refresh functionality,
# and for the OAuth contract it shares with every OAuth authenticator: host
# validation, OpenID discovery failures and token endpoint failures.
# Extends the base OAuthAuthenticatorTest class.
#
# Usage:
#   bundle exec ruby test/auth/client_credentials_authenticator_test.rb

# noinspection RubyResolve
require 'test_helper'
require 'minitest/autorun'
require 'time'
require_relative 'oauth_authenticator_test'

module Zitadel
  module Client
    module Auth
      ##
      # Test suite for the ClientCredentialsAuthenticator class.
      #
      # This suite verifies that the authenticator correctly builds tokens,
      # handles refresh logic, and respects configuration values passed to its builder.
      #
      # @example
      #   authenticator = ClientCredentialsAuthenticator.builder(oauth_host, "client-id", "secret")
      #                    .scopes("openid", "foo")
      #                    .build
      #   # use authenticator methods to verify token refresh functionality
      #
      class ClientCredentialsAuthenticatorTest < OAuthAuthenticatorTest
        HOST = 'https://zitadel.example.com'
        DISCOVERY = { issuer: HOST, token_endpoint: "#{HOST}/oauth/v2/token" }.to_json

        # An ApiClient that records token requests and answers with canned
        # responses, so no contract test reaches a real host.
        class StubApiClient < ::Zitadel::Client::ApiClient
          attr_reader :bodies

          def initialize(discovery, token)
            super()
            @discovery = discovery
            @token = token
            @bodies = []
          end

          def send_request(_method, url, _headers, body, no_redirect: false) # rubocop:disable Lint/UnusedMethodArgument
            return @discovery if url.end_with?('/.well-known/openid-configuration')

            @bodies << body.to_s
            @token
          end
        end

        def response(status, body)
          ::Zitadel::Client::ApiHttpResponse.new(status_code: status, body: body, headers: {})
        end

        def stubbed(api_client, host = HOST)
          authenticator = ClientCredentialsAuthenticator.builder(host, 'client-1', 'client-secret').build
          authenticator.api_client = api_client
          authenticator
        end

        def token_stubbed(status, body)
          stubbed(StubApiClient.new(response(200, DISCOVERY), response(status, body)))
        end

        # Asserts the block raises exactly +klass+ (not a subclass) and returns the error.
        def assert_raises_exactly(klass, &)
          error = assert_raises(klass, &)
          assert_instance_of klass, error
          error
        end

        def setup
          @authenticator = ClientCredentialsAuthenticator
                           .builder(oauth_host, 'dummy-client', 'dummy-secret')
                           .scopes('openid', 'foo')
                           .build
          inject_api_client(@authenticator)
        end

        ##
        # @return [void]
        #
        # Ensures the generated access token is present and not empty.
        #
        # This verifies that the authenticator is capable of producing
        # a valid access token under normal conditions.
        def test_access_token_is_not_empty
          token = @authenticator.auth_token

          refute_nil token
          refute_empty token
        end

        ##
        # @return [void]
        #
        # Validates that the Authorization header contains the correct Bearer token.
        #
        # This ensures that consumers of the authenticator can retrieve properly
        # formatted headers for authenticated HTTP requests.
        def test_auth_headers_contains_bearer_token
          token = @authenticator.refresh_token

          expected = { 'Authorization' => "Bearer #{token}" }

          assert_equal expected, @authenticator.auth_headers
        end

        ##
        # @return [void]
        #
        # Ensures that `refresh_token` returns a usable, non-expired token.
        #
        # This test confirms that token refresh behavior works correctly
        # and produces a valid, active token that has not yet expired.
        def test_refresh_token_returns_valid_token
          token = @authenticator.refresh_token

          refute_nil token
        end

        ##
        # @return [void]
        #
        # Asserts that the latest access token matches the token returned by `auth_token`.
        #
        # This verifies that the authenticator memoizes or reuses the token internally as expected.
        def test_auth_token_matches_refreshed_token
          token = @authenticator.refresh_token

          assert_equal token, @authenticator.auth_token
        end

        ##
        # @return [void]
        #
        # Ensures the authenticator uses the configured OAuth host.
        #
        # This verifies that the `host` parameter passed into the builder
        # is correctly retained and exposed via the `#host` method.
        def test_authenticator_honors_supplied_host
          assert_equal oauth_host, @authenticator.host
        end

        ##
        # @return [void]
        #
        # Verifies that each call to `refresh_token` returns a unique token.
        #
        # This confirms that the authenticator does not cache or reuse tokens
        # and generates fresh credentials on demand.
        def test_refresh_token_produces_unique_tokens
          token1 = @authenticator.refresh_token
          token2 = @authenticator.refresh_token

          refute_equal token1, token2
        end

        ##
        # @return [void]
        #
        # Verifies that the client secret is masked in both #inspect and #to_s
        # while the client id stays visible.
        def test_redacts_secret
          secret = 'super-secret-credential-value'
          open_id = OpenId.new('https://example.zitadel.cloud')
          auth = ClientCredentialsAuthenticator.new(open_id, 'visible-client-id', secret, 'openid')
          auth.instance_variable_set(:@access_token, secret)

          rendered = auth.inspect + auth.to_s
          refute_includes rendered, secret
          assert_includes rendered, '***'
          assert_includes auth.inspect, 'visible-client-id'
        end

        def test_mints_and_caches_token
          api_client = StubApiClient.new(response(200, DISCOVERY),
                                         response(200, { access_token: 't0k3n', expires_in: 3600 }.to_json))
          authenticator = stubbed(api_client)

          assert_equal 't0k3n', authenticator.auth_token
          assert_equal({ 'Authorization' => 'Bearer t0k3n' }, authenticator.auth_headers)
          assert_equal 1, api_client.bodies.size
          assert api_client.bodies.first.start_with?('grant_type=client_credentials&scope=openid')
        end

        def test_rejects_empty_credentials
          assert_raises_exactly(ArgumentError) { ClientCredentialsAuthenticator.builder(HOST, '', 'client-secret') }
          assert_raises_exactly(ArgumentError) { ClientCredentialsAuthenticator.builder(HOST, 'client-1', ' ') }
        end

        def test_rejects_bad_host
          ['', 'ftp://example.com', 'https://'].each do |host|
            error = assert_raises_exactly(ArgumentError) do
              ClientCredentialsAuthenticator.builder(host, 'client-1', 'client-secret')
            end
            refute_kind_of ::Zitadel::Client::ZitadelError, error
          end
        end

        def test_requires_api_client
          authenticator = ClientCredentialsAuthenticator.builder(HOST, 'client-1', 'client-secret').build

          assert_raises_exactly(RuntimeError) { authenticator.auth_token }
        end

        def test_discovery_unreachable
          authenticator = stubbed(::Zitadel::Client::DefaultApiClient.new(::Zitadel::Client::TransportOptions.builder.build),
                                  'http://127.0.0.1:1')

          error = assert_raises_exactly(::Zitadel::Client::Errors::NetworkError) { authenticator.auth_token }
          assert_kind_of ::Zitadel::Client::ApiError, error
          assert_equal 0, error.status_code
        end

        def test_discovery_non2xx
          error = assert_raises_exactly(::Zitadel::Client::Errors::NotFoundError) do
            stubbed(StubApiClient.new(response(404, '{}'), response(200, '{}'))).auth_token
          end
          assert_equal 404, error.status_code
          assert_kind_of ::Zitadel::Client::ZitadelError, error

          assert_raises_exactly(::Zitadel::Client::Errors::InternalServerError) do
            stubbed(StubApiClient.new(response(500, '{}'), response(200, '{}'))).auth_token
          end
        end

        def test_discovery_malformed
          ['not json', '[]', '{"issuer":"x"}'].each do |body|
            error = assert_raises_exactly(::Zitadel::Client::SerializationError) do
              stubbed(StubApiClient.new(response(200, body), response(200, '{}'))).auth_token
            end
            assert_kind_of ::Zitadel::Client::ZitadelError, error
          end
        end

        def test_token_endpoint_rejects
          error = assert_raises_exactly(::Zitadel::Client::Errors::OAuth2ServerError) do
            token_stubbed(401, { error: 'invalid_client', error_description: 'bad' }.to_json).auth_token
          end
          assert_equal 401, error.status_code
          assert_equal 'invalid_client', error.code
          assert_equal 'bad', error.description
          assert_kind_of ::Zitadel::Client::ZitadelError, error
          refute_kind_of ::Zitadel::Client::ApiError, error

          raw = assert_raises_exactly(::Zitadel::Client::Errors::OAuth2ServerError) { token_stubbed(503, 'down').auth_token }
          assert_equal 503, raw.status_code
          assert_equal 'down', raw.raw_body
        end

        def test_token_endpoint_unusable
          ['{"token_type":"Bearer"}', 'not json', '{"access_token":""}'].each do |body|
            error = assert_raises_exactly(::Zitadel::Client::Errors::OAuth2TokenError) do
              token_stubbed(200, body).auth_token
            end
            assert_kind_of ::Zitadel::Client::ZitadelError, error
          end
        end

        def test_rejects_bad_scopes
          builder = ClientCredentialsAuthenticator.builder(HOST, 'client-1', 'client-secret')

          [[], ['open id'], ['']].each do |auth_scopes|
            assert_raises_exactly(ArgumentError) { builder.scopes(*auth_scopes) }
          end
        end

        def test_joins_scopes
          api_client = StubApiClient.new(response(200, DISCOVERY), response(200, '{"access_token":"t"}'))
          authenticator = ClientCredentialsAuthenticator.builder(HOST, 'client-1', 'client-secret')
                                                        .scopes('openid', 'profile', 'openid')
                                                        .build
          authenticator.api_client = api_client

          authenticator.auth_token

          assert_includes api_client.bodies.first, '&scope=openid+profile&'
        end
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength, Metrics/AbcSize, Metrics/MethodLength
