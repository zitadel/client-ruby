# frozen_string_literal: true

require 'typhoeus'
require 'uri'
require 'json'

module Zitadel
  module Client
    # A self-contained, Typhoeus-based API client implementation.
    #
    # This client supports custom Typhoeus configuration via an optional block,
    # allowing proxy settings, additional headers, disabling SSL verification, etc.
    #
    # Example:
    #   require 'zitadel/client'
    #
    #   # 1) Create Configuration
    #   config = Zitadel::Client::Configuration.new(
    #     authenticator: Zitadel::Client::Auth::PersonalAccessTokenAuthenticator.new(
    #       'https://api.example.com',
    #       'test-token'
    #     )
    #   )
    #
    #   # 2) Instantiate DefaultApiClient with a block to configure Typhoeus options
    #   api_client = Zitadel::Client::DefaultApiClient.new(config) do |opts|
    #     # Set HTTP/S proxy
    #     opts[:proxy] = 'http://username:password@proxy.example.com:3128'
    #
    #     # Add a custom header to every request (will be merged with default headers)
    #     opts[:headers] = { 'X-My-Custom-Header' => 'custom-value' }
    #
    #     # Disable SSL certificate verification
    #     opts[:ssl_verifypeer] = false
    #     opts[:ssl_verifyhost] = 0
    #
    #     opts
    #   end
    class DefaultApiClient
      include IApiClient

      VALID_METHODS = %i[get post put patch delete head options].freeze

      # Initializes the DefaultApiClient.
      #
      # @param config [Configuration] The client configuration.
      def initialize(config)
        @config = config
        @serde = ObjectSerializer.new
      end

      # rubocop:disable Metrics/ParameterLists, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      def invoke_api(operation_id:, path_template:, method:, path_params:, query_params:, header_params:, body: nil,
                     success_type: nil, error_types: {})
        raise ArgumentError, "Invalid HTTP method: #{method}" unless VALID_METHODS.include?(method.downcase.to_sym)

        final_path = build_path(path_template, path_params)
        url = @config.host + final_path

        default_headers = {
          'Accept' => 'application/json',
          'Authorization' => "Bearer #{@config.access_token}",
          'User-Agent' => @config.user_agent,
          'X-Operation-Id' => operation_id
        }
        headers = default_headers.merge(header_params)

        request_body = nil
        if body
          headers['Content-Type'] = 'application/json'
          request_body = @serde.serialize(body).to_json
        end

        request = Typhoeus::Request.new(
          url,
          method: method.downcase.to_sym,
          params: query_params,
          body: request_body,
          headers: headers,
          timeout: @config.timeout,
          connecttimeout: @config.connect_timeout
        )

        response = request.run

        if response.success?
          return nil unless success_type && !response.body.empty?

          begin
            @serde.deserialize(response.body, success_type)
          rescue StandardError => e
            raise "Failed to deserialize successful response: #{e.message}"
          end

        else
          error_class = find_error_type(response.code, error_types)
          error_body = nil

          if error_class
            begin
              error_body = @serde.deserialize(response.body, error_class)
            rescue StandardError
              # Fallback to the parsed hash if deserialization fails
            end
          end

          raise ApiError.new(response.response_code, response.headers.to_h, error_body)
        end
      end
      # rubocop:enable Metrics/ParameterLists, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

      private

      # Finds the appropriate error class for a given HTTP status code.
      #
      # The lookup follows a specific order of precedence:
      # 1. The exact status code (e.g., 404).
      # 2. The status code family (e.g., "4XX" for a 404 status code).
      # 3. A "default" key.
      #
      # @param status_code [Integer] The HTTP status code.
      # @param error_types [Hash, nil] A map of status codes to class types.
      # @return [Class, nil] The found class type or nil if no match is found.
      def find_error_type(status_code, error_types)
        return nil if error_types.nil?

        family = "#{status_code / 100}XX"

        error_types[status_code] || error_types[family] || error_types['default']
      end

      # Builds a URL path by substituting placeholders with encoded values.
      #
      # @param path_template [String] The URL path with placeholders like /users/{id}.
      # @param path_params [Hash] The parameters to substitute.
      # @return [String] The final, resolved URL path.
      def build_path(path_template, path_params)
        result = path_template.dup
        path_params.each do |key, value|
          encoded_value = URI.encode_www_form_component(value.to_s)
          result.gsub!("{#{key}}", encoded_value)
        end
        result
      end
    end
  end
end
