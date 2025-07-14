# frozen_string_literal: true

module Zitadel
  module Client
    # Configuration class for the Zitadel::Client SDK.
    class Configuration
      # Initializes a new instance of the API client.
      #
      # @param authenticator [Authenticator] The authenticator for signing requests.
      # @param timeout [Integer] The total request timeout in seconds.
      # @param connect_timeout [Integer] The connection timeout in seconds.
      # rubocop:disable Metrics/MethodLength
      def initialize(authenticator, timeout = 30, connect_timeout = 5)
        @authenticator = authenticator
        @timeout = timeout
        @connect_timeout = connect_timeout
        @user_agent = [
          "zitadel-client/#{VERSION}",
          [
            'lang=ruby',
            "lang_version=#{RUBY_VERSION}",
            "os=#{RUBY_PLATFORM}",
            "arch=#{RbConfig::CONFIG['host_cpu']}"
          ].join('; ')
            .prepend('(').concat(')')
        ].join(' ')
      end
      # rubocop:enable Metrics/MethodLength

      # The access token for OAuth.
      #
      # @return [String] Access token for OAuth.
      def access_token
        @authenticator.send(:auth_token)
      end

      # The host.
      #
      # @return [String] Host.
      def host
        @authenticator.send(:host)
      end

      ##
      # Allows modifying the current instance using a configuration block.
      #
      # @yieldparam [Configuration] self
      def configure
        yield(self) if block_given?
      end

      private

      # @return [Authenticator] The authenticator for signing requests.
      attr_reader :authenticator

      # @return [Integer] The total request timeout in seconds.
      attr_reader :timeout

      # @return [Integer] The connection timeout in seconds.
      attr_reader :connect_timeout

      # @return [String] The user agent of the api client.
      attr_reader :user_agent
    end
  end
end
