# frozen_string_literal: true

# noinspection RubyResolve
require 'test_helper'
require 'minitest/autorun'
require 'minitest/hooks/test'
require 'testcontainers'
require 'net/http'
require 'json'
require 'logger'
require 'typhoeus'

module Zitadel
  module Client
    class ErrorModel
      attr_accessor :error_code, :field

      def self.attribute_map
        {
          error_code: :errorCode,
          field: :field
        }
      end

      def self.openapi_types
        {
          error_code: 'String',
          field: 'String'
        }
      end

      def self.build_from_hash(attributes)
        return nil unless attributes.is_a?(Hash)

        transformed_hash = {}
        attributes.each do |key, value|
          ruby_key = attribute_map.key(key.to_sym)
          transformed_hash[ruby_key] = value if ruby_key
        end

        new(transformed_hash)
      end

      def initialize(attributes = {})
        self.error_code = attributes[:error_code] if attributes.key?(:error_code)
        return unless attributes.key?(:field)

        self.field = attributes[:field]
      end
    end

    class SuccessModel
      attr_accessor :status

      def self.attribute_map
        {
          status: :status
        }
      end

      def self.openapi_types
        {
          status: 'String'
        }
      end

      def self.build_from_hash(attributes)
        return nil unless attributes.is_a?(Hash)

        transformed_hash = {}
        attributes.each do |key, value|
          ruby_key = attribute_map.key(key.to_sym)
          transformed_hash[ruby_key] = value if ruby_key
        end

        new(transformed_hash)
      end

      def initialize(attributes = {})
        return unless attributes.key?(:status)

        self.status = attributes[:status]
      end
    end

    # rubocop:disable Metrics/ClassLength, Metrics/MethodLength
    class DefaultApiClientTest < Minitest::Test
      include Minitest::Hooks

      # Set up the Docker container before any tests are run.
      #
      # Initializes a GenericContainer with the specified image, exposes port
      # 8080, and applies an HTTP wait strategy. Constructs the OAuth host URL
      # directly without intermediate variables.
      def before_all
        super
        @mock_server = Testcontainers::DockerContainer
                       .new('wiremock/wiremock:3.5.2')
                       .with_exposed_port(8080)
                       .start

        @mock_server.wait_for_http(container_port: 8080, path: '/__admin/mappings', status: 200)

        # noinspection HttpUrlsUsage
        @oauth_host = "http://#{@mock_server.host}:#{@mock_server.mapped_port(8080)}"

        stubs = File.read(File.join(File.dirname(__FILE__), 'resources/api.json'))
        mappings = JSON.parse(stubs)['mappings']

        mappings.each do |mapping|
          Typhoeus.post("#{@oauth_host}/__admin/mappings", body: mapping.to_json,
                                                           headers: { 'Content-Type' => 'application/json' })
        end
      end

      # Tear down the Docker container after all tests are run.
      #
      # Stops the container if it was started.
      def after_all
        @mock_server&.stop
        @mock_server&.remove
        super
      end

      # Test GET request is successful.
      def test_get_request
        config = Configuration.new(Auth::NoAuthAuthenticator.new(@oauth_host, 'test-token'))
        api_client = DefaultApiClient.new(config)

        response = api_client.invoke_api(
          operation_id: 'testGetSuccess',
          path_template: '/users/123',
          method: 'GET',
          path_params: {},
          query_params: {},
          header_params: {},
          body: nil,
          success_type: SuccessModel,
          error_types: {
            200 => SuccessModel
          }
        )

        assert_instance_of SuccessModel, response
      end

      # Test POST request is successful.
      def test_post_request
        config = Configuration.new(Auth::NoAuthAuthenticator.new(@oauth_host, 'test-token'))
        api_client = DefaultApiClient.new(config)

        response_types = {
          201 => SuccessModel
        }

        response = api_client.invoke_api(
          operation_id: 'testPost',
          path_template: '/users',
          method: 'POST',
          path_params: {},
          query_params: {},
          header_params: {},
          body: { name: 'John' },
          success_type: SuccessModel,
          error_types: response_types
        )

        assert_instance_of SuccessModel, response
      end

      # Test PUT request sends custom headers.
      def test_sends_custom_headers
        config = Configuration.new(Auth::NoAuthAuthenticator.new(@oauth_host, 'test-token'))
        api_client = DefaultApiClient.new(config)

        api_client.invoke_api(
          operation_id: 'testCustomHeaders',
          path_template: '/users/123',
          method: 'PUT',
          path_params: {},
          query_params: {},
          header_params: {
            'X-Request-ID' => 'test-uuid-123'
          },
          body: {},
          success_type: SuccessModel,
          error_types: {
            200 => SuccessModel
          }
        )

        pass
      end

      # Test DELETE request returns void.
      def test_delete_request
        config = Configuration.new(Auth::NoAuthAuthenticator.new(@oauth_host, 'test-token'))
        api_client = DefaultApiClient.new(config)

        response = api_client.invoke_api(
          operation_id: 'testVoid',
          path_template: '/users/123',
          method: 'DELETE',
          path_params: {},
          query_params: {},
          header_params: {},
          body: nil,
          success_type: SuccessModel,
          error_types: {}
        )

        assert_nil response
      end

      # Test handling of 404 Not Found error.
      def test_api_client_error_response
        config = Configuration.new(Auth::NoAuthAuthenticator.new(@oauth_host, 'test-token'))
        api_client = DefaultApiClient.new(config)

        assert_raises ApiError do
          api_client.invoke_api(
            operation_id: 'test404',
            path_template: '/users/notfound',
            method: 'GET',
            path_params: {},
            query_params: {},
            header_params: {},
            body: nil,
            success_type: SuccessModel,
            error_types: {}
          )
        end
      end

      # Test handling of 400 Bad Request with a typed error model.
      def test_typed_client_error_response
        config = Configuration.new(Auth::NoAuthAuthenticator.new(@oauth_host, 'test-token'))
        api_client = DefaultApiClient.new(config)

        exception = assert_raises ApiError do
          api_client.invoke_api(
            operation_id: 'test400',
            path_template: '/users/bad',
            method: 'POST',
            path_params: {},
            query_params: {},
            header_params: {},
            body: {},
            success_type: SuccessModel,
            error_types: {
              400 => ErrorModel
            }
          )
        end

        assert_instance_of ErrorModel, exception.response_body
      end

      # Test handling of malformed JSON response.
      def test_deserialization_failure
        config = Configuration.new(Auth::NoAuthAuthenticator.new(@oauth_host, 'test-token'))
        api_client = DefaultApiClient.new(config)

        assert_raises RuntimeError do
          api_client.invoke_api(
            operation_id: 'testMalformed',
            path_template: '/malformed',
            method: 'GET',
            path_params: {},
            query_params: {},
            header_params: {},
            body: nil,
            success_type: SuccessModel,
            error_types: {
              200 => SuccessModel
            }
          )
        end
      end

      # rubocop:enable Metrics/ClassLength, Metrics/MethodLength
    end
  end
end
