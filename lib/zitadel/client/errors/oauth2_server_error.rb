# frozen_string_literal: true

module Zitadel
  module Client
    module Errors
      ##
      # Error for an OAuth2 token endpoint that answered with a non-2xx status.
      #
      # Carries the RFC 6749 section 5.2 error fields when the response body
      # holds a well-formed OAuth2 error object, and the raw body in every case.
      class OAuth2ServerError < ::Zitadel::Client::ZitadelError
        # @return [Integer] the HTTP status code of the token response
        attr_reader :status_code
        # @return [String, nil] the RFC 6749 error code, or nil when the body held no OAuth2 error object
        attr_reader :code
        # @return [String, nil] the human-readable error description, if present
        attr_reader :description
        # @return [String, nil] a URI describing the error, if present
        attr_reader :uri
        # @return [String] the raw token response body
        attr_reader :raw_body

        def initialize(status_code, code, description, uri, raw_body)
          super(self.class.build_message(status_code, code, description, raw_body))
          @status_code = status_code
          @code = code
          @description = description
          @uri = uri
          @raw_body = raw_body
        end

        # Builds the error message from the response fields.
        def self.build_message(status_code, code, description, raw_body)
          return "Token request failed with status #{status_code}: #{raw_body}" if code.nil?
          return "Token request failed with status #{status_code}: #{code} -- #{description}" unless description.nil?

          "Token request failed with status #{status_code}: #{code}"
        end
      end
    end
  end
end
