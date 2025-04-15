module ZitadelClient
  ##
  # Represents an HTTP error returned from the Zitadel API.
  #
  # This class captures the HTTP status code, headers, and body,
  # and provides a helpful string representation for debugging.
  #
  class ApiError < StandardError
    # @return [Integer, nil] HTTP status code (e.g., 404, 500)
    attr_reader :code

    # @return [Hash, nil] HTTP response headers
    attr_reader :response_headers

    # @return [String, nil] HTTP response body as a string
    attr_reader :response_body

    ##
    # Initializes an ApiError instance.
    #
    # @param arg [String, Hash, nil] Error message or options hash
    #
    # Examples:
    #   ApiError.new("Internal Server Error")
    #   ApiError.new(code: 500, response_headers: {}, response_body: "Oops")
    # noinspection RubyMismatchedVariableType
    def initialize(arg = nil)
      if arg.is_a?(Hash)
        super(arg[:message] || arg['message'] || arg.to_s)

        @code             = arg[:code] || arg['code']
        @response_headers = arg[:response_headers] || arg['response_headers']
        @response_body    = arg[:response_body] || arg['response_body']
        @message          = arg[:message] || arg['message']
      else
        # noinspection RubyMismatchedArgumentType
        super(arg)
        @message = arg
      end
    end

    ##
    # Returns a formatted error message including status and response details.
    #
    # @return [String]
    def message
      msg = @message || "Error message: the server returned an error"
      msg += "\nHTTP status code: #{code}" if code
      msg += "\nResponse headers: #{response_headers}" if response_headers
      msg += "\nResponse body: #{response_body}" if response_body
      msg
    end

    ##
    # Alias to `message` for better exception output.
    #
    # @return [String]
    def to_s
      message
    end
  end
end
