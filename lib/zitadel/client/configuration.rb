# frozen_string_literal: true

module Zitadel
  module Client
    ##
    # Configuration class for the Zitadel::Client SDK.
    #
    # This class defines all client-level options including timeouts,
    # logging, SSL behavior, and validation controls. It allows you
    # to customize how API calls are made and handled internally.
    #
    # Example:
    #
    #   config = Zitadel::Client::Configuration.new do |c|
    #     c.debugging = true
    #     c.timeout = 10
    #     c.verify_ssl = true
    #   end
    #
    # noinspection RubyTooManyInstanceVariablesInspection
    class Configuration
      USER_AGENT = [
        "zitadel-client/#{VERSION}",

        [
          'lang=ruby',
          "lang_version=#{RUBY_VERSION}",
          "os=#{RUBY_PLATFORM}",
          "arch=#{RbConfig::CONFIG['host_cpu']}"
        ].join('; ')
          .prepend('(').concat(')')
      ].join(' ')

      ##
      # The authentication strategy used to authorize requests.
      #
      # This is typically an instance of a class implementing an interface
      # like `#authenticate(request)`, such as `NoAuthAuthenticator` or
      # a custom implementation.
      #
      # @return [Authenticator] the authenticator instance
      attr_reader :authenticator

      ##
      # Enables or disables debug logging.
      #
      # When enabled, HTTP request and response details are logged
      # via the configured `logger` instance.
      #
      # @return [Boolean]
      attr_accessor :debugging

      ##
      # The logger used to output debugging information.
      #
      # Defaults to `Rails.logger` if Rails is defined; otherwise,
      # logs to STDOUT.
      #
      # @return [#debug]
      attr_accessor :logger

      ##
      # Directory path used to temporarily store files returned
      # by API responses (e.g., when downloading files).
      #
      # @return [String]
      attr_accessor :temp_folder_path

      ##
      # Request timeout duration in seconds.
      #
      # If set to `0`, requests will never time out.
      #
      # @return [Integer]
      attr_accessor :timeout

      ##
      # Enables or disables client-side request validation.
      #
      # When disabled, validation of input parameters is skipped.
      # Defaults to `true`.
      #
      # @return [Boolean]
      attr_accessor :client_side_validation

      ##
      # Controls whether SSL certificates are verified when
      # making HTTPS requests.
      #
      # Set to `false` to bypass certificate verification. Defaults to `true`.
      # **Note:** This should always be `true` in production.
      #
      # @return [Boolean]
      attr_accessor :verify_ssl

      ##
      # Controls whether SSL hostnames are verified during
      # HTTPS communication.
      #
      # Set to `false` to skip hostname verification. Defaults to `true`.
      # **Note:** Disabling this weakens transport security.
      #
      # @return [Boolean]
      attr_accessor :verify_ssl_host

      ##
      # Path to the certificate file used to verify the peer.
      #
      # This is used in place of system-level certificate stores.
      #
      # @return [String]
      #
      # @see https://github.com/typhoeus/typhoeus/blob/master/lib/typhoeus/easy_factory.rb#L145
      attr_accessor :ssl_ca_cert

      ##
      # Path to the client certificate file for mutual TLS (mTLS).
      #
      # This is optional and only required when server expects
      # client-side certificates.
      #
      # @return [String]
      attr_accessor :cert_file

      ##
      # Path to the private key file for the client certificate.
      #
      # Used with `cert_file` during mutual TLS authentication.
      #
      # @return [String]
      attr_accessor :key_file

      ##
      # Custom encoding strategy for query parameters that are arrays.
      #
      # Set this if your server expects a specific collection format
      # (e.g., `multi`, `csv`, etc.). Defaults to `nil`.
      #
      # @return [Symbol, nil]
      #
      # @see https://github.com/typhoeus/ethon/blob/master/lib/ethon/easy/queryable.rb#L96
      attr_accessor :params_encoding

      ##
      # The User-Agent header to be sent with HTTP requests.
      #
      # Set this to identify your client or library when making requests.
      #
      # @return [String, nil]
      attr_accessor :user_agent

      # rubocop:disable Metrics/MethodLength
      def initialize(authenticator = Auth::NoAuthAuthenticator.new)
        @authenticator = authenticator
        @client_side_validation = true
        @verify_ssl = true
        @verify_ssl_host = true
        @cert_file = nil
        @key_file = nil
        @timeout = 0
        @params_encoding = nil
        @debugging = false
        @logger = nil
        @user_agent = USER_AGENT

        yield(self) if block_given?
      end

      # rubocop:enable Metrics/MethodLength

      ##
      # Allows modifying the current instance using a configuration block.
      #
      # @yieldparam [Configuration] self
      def configure
        yield(self) if block_given?
      end
    end
  end
end
