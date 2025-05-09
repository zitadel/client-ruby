# frozen_string_literal: true

module ZitadelClient
  module Auth
    ##
    # Personal Access Token Authenticator.
    #
    # Uses a static personal access token for API authentication.
    #
    class PersonalAccessTokenAuthenticator < Authenticator
      ##
      # Initializes the PersonalAccessTokenAuthenticator with host and token.
      #
      # @param host [String] the base URL for the service.
      # @param token [String] the personal access token.
      #
      def initialize(host, token)
        # noinspection RubyArgCount
        super(ZitadelClient::Utils::UrlUtil.build_hostname(host))
        @token = token
      end

      protected

      ##
      # Returns the authentication headers using the personal access token.
      #
      # @return [Hash{String => String}] a hash containing the 'Authorization' header.
      #
      def auth_headers
        { 'Authorization' => "Bearer #{@token}" }
      end
    end
  end
end
