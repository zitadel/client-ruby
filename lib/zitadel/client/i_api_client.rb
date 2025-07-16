# frozen_string_literal: true

module Zitadel
  module Client
    # Defines the contract for an API client that can invoke API operations.
    # noinspection RubyUnusedLocalVariable
    module IApiClient
      # Invokes a remote API endpoint.
      #
      # @param operation_id [String] A unique identifier for the API operation.
      # @param path_template [String] The URL path template (e.g., /users/{id}).
      # @param method [Symbol] The HTTP method (e.g., :get, :post).
      # @param path_params [Hash] A hash of parameters to substitute into the path template.
      # @param query_params [Hash] A hash of query parameters to append to the URL.
      # @param header_params [Hash] A hash of custom HTTP headers.
      # @param body [Object, nil] The request body, typically a serializable object.
      # @param success_type [Class, nil] The expected response type for a successful (2xx) response.
      # @param error_types [Hash, nil] A map of status codes (e.g., 404, "4XX", "default") to error response types.
      # @return [Object, nil] The deserialized response object on success, or nil if the success_type is not provided.
      # rubocop:disable Metrics/ParameterLists
      def invoke_api(operation_id:,
                     path_template:,
                     method:,
                     path_params:,
                     query_params:,
                     header_params:,
                     body: nil,
                     success_type: nil,
                     error_types: {})
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end
      # rubocop:enable Metrics/ParameterLists
    end
  end
end
