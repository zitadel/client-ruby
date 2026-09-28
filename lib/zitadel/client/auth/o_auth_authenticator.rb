# frozen_string_literal: true

require 'json'
require 'uri'

module Zitadel
  module Client
    module Auth
      ##
      # Abstract base class for OAuth-based, token-minting authenticators.
      #
      # Mints a bearer token by POSTing an OAuth2 grant (client-credentials or a
      # signed JWT-bearer assertion) to the provider's token endpoint, then
      # attaches the resulting access token on every API request. The minted
      # token is cached together with its expiry and only re-minted once it is
      # within the refresh skew of expiring.
      #
      # Token-minting requires an outbound HTTP call, so this class includes
      # HttpAwareAuthenticator: the shared ApiClient is injected by the Zitadel
      # constructor and both OpenID discovery and the token POST are sent
      # through it. A token request fails with:
      #
      # - RuntimeError when no ApiClient has been injected;
      # - Errors::NetworkError or Errors::NetworkTimeoutError when no HTTP
      #   response arrived;
      # - Errors::OAuth2ServerError when the token endpoint answered with a
      #   non-2xx status;
      # - Errors::OAuth2TokenError when it answered 2xx without a usable access
      #   token.
      class OAuthAuthenticator < BaseAuthenticator
        include HttpAwareAuthenticator

        # Seconds before expiry at which a cached token is treated as stale.
        REFRESH_SKEW_SECONDS = 300

        # Headers sent with every token request.
        TOKEN_REQUEST_HEADERS = {
          'Content-Type' => 'application/x-www-form-urlencoded',
          'Accept' => 'application/json'
        }.freeze

        # @return [String] the space-delimited scope string for the token request
        attr_reader :scope

        ##
        # @param open_id [OpenId] the OpenID discovery helper for the target host
        # @param scope [String] the space-delimited scope string for the token request
        def initialize(open_id, scope)
          super()
          @open_id = open_id
          @scope = scope
          @api_client = nil
          @access_token = nil
          @expires_at = nil
          @mutex = Thread::Mutex.new
        end

        # @param client [ApiClient] the shared transport
        attr_writer :api_client

        # @return [String] the normalised host endpoint
        def host
          @open_id.host_endpoint
        end

        # @return [Hash{String => String}] the Authorization header
        def auth_headers
          { 'Authorization' => "Bearer #{auth_token}" }
        end

        ##
        # Returns a valid access token, minting (or re-minting) one if the cache
        # is empty or within the refresh skew of expiring.
        #
        # @return [String] the access token
        def auth_token
          @mutex.synchronize do
            @access_token.nil? || stale? ? mint_token : @access_token
          end
        end

        ##
        # Exchanges the configured grant for a fresh access token and caches it.
        #
        # @return [String] the freshly minted access token
        def refresh_token
          @mutex.synchronize { mint_token }
        end

        # Redacts the cached access token.
        def inspect
          "#<#{self.class.name} host=#{host.inspect} scope=#{@scope.inspect} access_token=#{masked_token.inspect}>"
        end

        alias to_s inspect

        protected

        # @return [String] the OAuth2 grant_type value sent in the token request
        def grant_type
          raise NotImplementedError, "#{self.class}#grant_type must be implemented"
        end

        # @return [Hash{String => String}] grant-specific token-request parameters
        def token_request_params
          raise NotImplementedError, "#{self.class}#token_request_params must be implemented"
        end

        # @return [String, nil] '***' when a token is cached, nil otherwise
        def masked_token
          @access_token.nil? ? nil : '***'
        end

        private

        def stale?
          expires_at = @expires_at
          !expires_at.nil? && Time.now.to_f >= expires_at - REFRESH_SKEW_SECONDS
        end

        def mint_token
          response = post_token_request
          status = response.status_code
          raise server_error(status, response.body) unless status >= 200 && status < 300

          payload = parse_object(response.body)
          raise ::Zitadel::Client::Errors::OAuth2TokenError, 'Token response is not a JSON object' if payload.nil?

          cache_token(payload)
        end

        def cache_token(payload)
          access_token = payload['access_token']
          raise ::Zitadel::Client::Errors::OAuth2TokenError, 'Token response missing or empty access_token field' unless access_token.is_a?(String) && !access_token.empty?

          expires_in = payload['expires_in']
          @expires_at = expires_in.is_a?(Numeric) && expires_in.positive? ? Time.now.to_f + expires_in : nil
          @access_token = access_token
        end

        def post_token_request
          client = injected_api_client
          params = { 'grant_type' => grant_type, 'scope' => @scope }.merge(token_request_params)
          # never replay a token POST across a redirect: a malicious 307/308
          # could otherwise leak the assertion or secret.
          client.send_request(:POST, @open_id.token_endpoint(client), TOKEN_REQUEST_HEADERS,
                              URI.encode_www_form(params), no_redirect: true)
        end

        def injected_api_client
          client = @api_client
          return client unless client.nil?

          raise 'OAuthAuthenticator has no ApiClient; use it through the Zitadel client, ' \
                'which injects one before the first token request.'
        end

        def parse_object(body)
          payload = JSON.parse(body)
          payload.is_a?(Hash) ? payload : nil
        rescue JSON::ParserError
          nil
        end

        def server_error(status, body)
          payload = parse_object(body)
          code = payload&.fetch('error', nil)
          return ::Zitadel::Client::Errors::OAuth2ServerError.new(status, nil, nil, nil, body) if payload.nil? || !code.is_a?(String) || code.empty?

          description = payload['error_description']
          uri = payload['error_uri']
          ::Zitadel::Client::Errors::OAuth2ServerError.new(
            status, code, description.is_a?(String) ? description : nil, uri.is_a?(String) ? uri : nil, body
          )
        end
      end
    end
  end
end
