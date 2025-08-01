# frozen_string_literal: true

require 'time'
require 'oauth2'

OAuth2.configure do |config|
  # noinspection RubyResolve
  config.silence_extra_tokens_warning = true
end

module Zitadel
  module Client
    module Auth
      ##
      # Base class for OAuth-based authentication using an OAuth2 client.
      #
      # Attributes:
      #   open_id: An object providing OAuth endpoint information.
      #   auth_session: An OAuth2Session instance used for fetching tokens.
      #
      class OAuthAuthenticator < Authenticator
        protected

        ##
        # Constructs an OAuthAuthenticator.
        #
        # @param open_id [OpenId] An object that must implement `get_host_endpoint` and `get_token_endpoint`.
        # @param auth_session [OAuth2Session] The OAuth2Session instance used for token requests.
        #
        def initialize(open_id, auth_scopes, auth_session)
          super(open_id.host_endpoint)
          @open_id = open_id
          @token = nil
          @auth_session = auth_session
          @auth_scopes = auth_scopes.to_a.join(' ')
          @mutex = Thread::Mutex.new
        end

        ##
        # Returns the current access token, refreshing it if necessary.
        #
        # @return [String] The current access token.
        #
        def auth_token
          @mutex.synchronize do
            refresh_token if @token.nil? || @token.expired?

            raise 'Token is nil after refresh' if @token.nil?

            return @token.token
          end
        end

        ##
        # Retrieves authentication headers.
        #
        # @return [Hash{String => String}] A hash containing the 'Authorization' header.
        #
        def auth_headers
          { 'Authorization' => "Bearer #{auth_token}" }
        end

        ##
        # Builds and returns a hash of grant parameters required for the token request.
        #
        # The base class will invoke this method by passing its OAuth2 client.
        # The subclass implementation should return the result of either:
        #   client.client_credentials.get_token(scope: scopes)
        # or
        #   client.assertion.get_token(claims)
        #
        # @param auth_client [OAuth2::Client] The OAuth2 client instance.
        # @param [String] auth_scopes
        # @return [OAuth2::AccessToken] A hash of parameters used to fetch a token.
        #
        def get_grant(auth_client, auth_scopes)
          # :nocov:
          raise NotImplementedError, "#{self.class}#get_grant must be implemented"
          # :nocov:
        end

        ##
        # Refreshes the access token using the OAuth flow.
        #
        # It uses `get_grant` to obtain all necessary parameters for the token request.
        #
        # @return [OAuth2::AccessToken] A new Token instance.
        # @raise [RuntimeError] if the token refresh fails.
        #
        def refresh_token
          @token = get_grant(@auth_session, @auth_scopes)
        rescue StandardError => e
          raise ZitadelError.new("Failed to refresh token: #{e.message}"), cause: e
        end
      end
    end
  end
end
