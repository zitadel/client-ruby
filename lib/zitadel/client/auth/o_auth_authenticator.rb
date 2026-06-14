# frozen_string_literal: true

require 'json'
require 'uri'

module Zitadel
  module Client
    module Auth
      # Abstract base class for OAuth-based, token-minting authenticators.
      #
      # Mints a bearer token by POSTing an OAuth2 grant (client-credentials or a
      # signed JWT-bearer assertion) to the provider's token endpoint, then
      # attaches the resulting access token on every API request. The minted
      # token is cached together with its expiry and only re-minted once it is
      # within the refresh skew of expiring.
      #
      # Token-minting requires an outbound HTTP call, so this class includes
      # {HttpAwareAuthenticator}: the shared {ApiClient} is injected by the
      # {Client} constructor and the token POST is sent through it. Sharing the
      # SDK transport means token exchange honours the same proxy, TLS, timeout
      # and redirect configuration as regular API calls.
      #
      # Subclasses contribute the +grant_type+ and the grant-specific token
      # request parameters (scope, client_secret, assertion, ...).
      class OAuthAuthenticator < BaseAuthenticator
        include HttpAwareAuthenticator

        # Seconds before expiry at which a cached token is treated as stale and
        # re-minted.
        REFRESH_SKEW_SECONDS = 300

        # @param open_id [OpenId] Resolved OpenID configuration (host + token endpoint).
        # @param client_id [String] The OAuth2 client identifier.
        # @param scope [String] Space-delimited scope string for the token request.
        def initialize(open_id, client_id, scope)
          super()
          @open_id = open_id
          @client_id = client_id
          @scope = scope
          @api_client = nil
          @access_token = nil
          @expires_at = 0.0
          @mutex = Thread::Mutex.new
        end

        # Inject the shared API client used for the token exchange.
        # @!attribute [w] api_client
        #   @param client [ApiClient]
        #   @return [void]
        attr_writer :api_client

        # @return [String]
        def host
          @open_id.host_endpoint
        end

        # @return [Hash{String => String}]
        def auth_headers
          { 'Authorization' => "Bearer #{auth_token}" }
        end

        # Return a valid access token, minting (or re-minting) one if the cache
        # is empty or within the refresh skew of expiring.
        #
        # @return [String]
        # @raise [ApiError] if the token cannot be obtained.
        def auth_token
          @mutex.synchronize do
            if @access_token.nil? ||
               (@expires_at != 0 && Time.now.to_f >= (@expires_at - REFRESH_SKEW_SECONDS))
              refresh_token
            end

            raise ApiError.new(message: 'Token is nil even after attempting to refresh.') if @access_token.nil?

            @access_token
          end
        end

        # Mask the cached token so it never leaks through inspect / logging.
        def inspect
          masked = @access_token.nil? ? nil : '***'
          "#<#{self.class.name} host=#{host.inspect} client_id=#{@client_id.inspect} " \
            "scope=#{@scope.inspect} access_token=#{masked.inspect} expires_at=#{@expires_at.inspect}>"
        end
        alias to_s inspect

        protected

        # The OAuth2 grant_type value sent in the token request.
        # @return [String]
        def grant_type
          raise NotImplementedError, "#{self.class}#grant_type must be implemented"
        end

        # Grant-specific token-request parameters (e.g. scope, assertion).
        # @return [Hash{String => String}]
        def access_token_options
          raise NotImplementedError, "#{self.class}#access_token_options must be implemented"
        end

        private

        # Exchange the configured grant for a fresh access token and cache it.
        #
        # POSTs an +application/x-www-form-urlencoded+ body to the token endpoint
        # through the injected {ApiClient}. Wraps any failure in a {ZitadelError}
        # so callers see a single catchable error type.
        #
        # @return [String] the freshly minted access token.
        # @raise [ZitadelError] if the client is not yet injected or the exchange fails.
        def refresh_token
          response = post_token_request
          payload = parse_token_response(response)

          @access_token = payload['access_token']
          @expires_at = expires_at_from(payload['expires_in'])
          @access_token
        rescue ApiError, ZitadelError
          raise
        rescue StandardError => e
          raise ZitadelError.new("Failed to refresh token: #{e.message}"), cause: e
        end

        # POST the configured grant to the token endpoint through the injected
        # client and return the raw response.
        #
        # @return [ApiResponse]
        # @raise [ZitadelError] if no ApiClient has been injected.
        def post_token_request
          require_api_client!
          params = { 'grant_type' => grant_type }.merge(access_token_options)
          @api_client.send_request(
            'POST',
            @open_id.token_endpoint,
            { 'Content-Type' => 'application/x-www-form-urlencoded', 'Accept' => 'application/json' },
            URI.encode_www_form(params),
            # Never replay a token POST across a redirect — a malicious 307/308
            # could otherwise leak the assertion/secret.
            no_redirect: true
          )
        end

        # @raise [ZitadelError] unless the shared ApiClient has been injected.
        def require_api_client!
          return unless @api_client.nil?

          raise ZitadelError,
                'OAuthAuthenticator has no ApiClient; it must be used via ' \
                'Zitadel::Client::Client, which injects the shared transport before any token exchange.'
        end

        # Validate the token-endpoint response and return the decoded payload.
        #
        # @param response [ApiResponse]
        # @return [Hash] the parsed JSON payload containing the access token.
        # @raise [ApiError] on a non-2xx status, invalid JSON, or a missing access_token.
        def parse_token_response(response)
          if response.status_code < 200 || response.status_code >= 300
            raise token_error("token endpoint returned HTTP #{response.status_code}", response)
          end

          payload = decode_token_payload(response)
          unless payload.is_a?(Hash) && payload['access_token'].is_a?(String)
            raise token_error('token endpoint response did not contain an access_token.', response)
          end

          payload
        end

        # Parse the response body as JSON, mapping a parse failure onto an {ApiError}.
        #
        # @param response [ApiResponse]
        # @return [Object] the decoded JSON document.
        # @raise [ApiError] if the body is not valid JSON.
        def decode_token_payload(response)
          JSON.parse(response.body)
        rescue JSON::ParserError => e
          raise token_error('token endpoint response was not valid JSON.', response), cause: e
        end

        # Build an {ApiError} describing a token-refresh failure.
        #
        # @param detail [String] human-readable failure detail.
        # @param response [ApiResponse] the offending response.
        # @return [ApiError]
        def token_error(detail, response)
          ApiError.new(
            message: "Token refresh failed: #{detail}",
            status_code: response.status_code,
            response_headers: response.headers,
            response_body: response.body
          )
        end

        # Compute the absolute expiry timestamp from an +expires_in+ value,
        # falling back to +0.0+ (never expires) when it is absent or invalid.
        #
        # @param expires_in [Object] the token endpoint's expires_in field.
        # @return [Float]
        def expires_at_from(expires_in)
          return 0.0 unless expires_in.is_a?(Numeric) && expires_in.positive?

          lifetime = Float(expires_in) # : Float
          Time.now.to_f + lifetime
        end
      end

      # Abstract builder for constructing OAuth authenticator instances.
      #
      # Provides common configuration: the resolved {OpenId} instance (fetched
      # eagerly via OpenID discovery using the supplied transport options) and
      # the authentication scopes.
      class OAuthAuthenticatorBuilder
        DEFAULT_SCOPES = %w[openid urn:zitadel:iam:org:project:id:zitadel:aud].freeze

        # @return [OpenId]
        attr_reader :open_id

        # @return [Set<String>]
        attr_reader :auth_scopes

        # @return [TransportOptions]
        attr_reader :transport_options

        # @param host [String] The base URL for the OAuth provider.
        # @param transport_options [TransportOptions, nil] Optional transport options for TLS, proxy, and headers.
        def initialize(host, transport_options: nil)
          @transport_options = transport_options || TransportOptions.builder.build
          @open_id = OpenId.new(host, transport_options: @transport_options)
          @auth_scopes = DEFAULT_SCOPES.to_set
        end

        # Sets the authentication scopes for the OAuth authenticator.
        #
        # @param auth_scopes [Array<String>] scope strings.
        # @return [self]
        def scopes(*auth_scopes)
          @auth_scopes = auth_scopes.to_set
          self
        end
      end
    end
  end
end
