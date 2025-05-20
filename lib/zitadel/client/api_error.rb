# frozen_string_literal: true

module Zitadel
  module Client
    ##
    # Represents an HTTP error returned from the Zitadel API.
    #
    # Exposes the HTTP status code, response headers, and response body.
    class ApiError < ZitadelError
      # @return [Integer] HTTP status code
      attr_reader :code

      # @return [Hash{String=>Array<String>}] HTTP response headers
      attr_reader :response_headers

      # @return [String, Typhoeus::Response] HTTP response body
      attr_reader :response_body

      ##
      # @param code             [Integer]                     HTTP status code
      # @param response_headers [Hash{String=>Array<String>}] HTTP response headers
      # @param response_body    [String, Typhoeus::Response]  HTTP response body
      def initialize(code, response_headers, response_body)
        super("Error #{code}")
        @code = code
        @response_headers = response_headers
        @response_body = response_body
      end
    end
  end
end
