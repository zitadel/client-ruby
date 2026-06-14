# frozen_string_literal: true

module Zitadel
  module Client
    module Auth
      # Personal Access Token Authenticator.
      #
      # Uses a static personal access token (PAT) for API authentication. A PAT
      # is a long-lived bearer credential minted out-of-band in the Zitadel
      # console, so no token exchange is required: the token is attached verbatim
      # on every request. This authenticator therefore extends
      # {BaseAuthenticator} directly and does NOT need {HttpAwareAuthenticator}.
      class PersonalAccessTokenAuthenticator < BaseAuthenticator
        # @return [String]
        attr_reader :host

        # @param host [String] the base URL for the service.
        # @param token [String] the personal access token.
        def initialize(host, token)
          super()
          @host = self.class.build_hostname(host)
          @token = token
        end

        # @return [Hash{String => String}]
        def auth_headers
          { 'Authorization' => "Bearer #{@token}" }
        end

        # Mask the token so it never leaks through inspect / logging.
        def inspect
          "#<#{self.class.name} host=#{@host.inspect} token=\"***\">"
        end
        alias to_s inspect

        # Normalises a host into an absolute base URL, defaulting to https.
        # @param host [String]
        # @return [String]
        def self.build_hostname(host)
          host = host.strip
          # noinspection HttpUrlsUsage
          host = "https://#{host}" unless host.start_with?('http://', 'https://')
          host
        end
      end
    end
  end
end
