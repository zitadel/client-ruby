# frozen_string_literal: true

require 'json'
require 'uri'

module Zitadel
  module Client
    module Auth
      ##
      # Resolves the OpenID Connect discovery document for a Zitadel host.
      #
      # The constructor only validates and normalises the host; it performs no
      # I/O. The +token_endpoint+ is fetched through the shared ApiClient the
      # first time #token_endpoint is called, so discovery honours the SDK's
      # proxy, TLS and timeout settings and fails with the same error types as
      # any other request:
      #
      # - no HTTP response: Errors::NetworkError or Errors::NetworkTimeoutError;
      # - a non-2xx status: the ApiError subclass for that status;
      # - a body that is not a JSON object with a +token_endpoint+:
      #   SerializationError.
      class OpenId
        WELL_KNOWN_PATH = '/.well-known/openid-configuration'

        STATUS_ERRORS = {
          400 => ::Zitadel::Client::Errors::BadRequestError,
          401 => ::Zitadel::Client::Errors::UnauthorizedError,
          403 => ::Zitadel::Client::Errors::ForbiddenError,
          404 => ::Zitadel::Client::Errors::NotFoundError,
          409 => ::Zitadel::Client::Errors::ConflictError,
          422 => ::Zitadel::Client::Errors::UnprocessableEntityError,
          500 => ::Zitadel::Client::Errors::InternalServerError
        }.freeze

        # @return [String] the normalised host endpoint
        attr_reader :host_endpoint

        ##
        # Validates and normalises the host. A host without a scheme gets +https://+.
        #
        # @param host [String] the Zitadel instance host name or URL
        # @raise [ArgumentError] if the host is empty, uses a scheme other than
        #   http or https, or is not a valid URL
        def initialize(host)
          @host_endpoint = normalise_host(host)
          @well_known_url = URI.join(@host_endpoint, WELL_KNOWN_PATH).to_s
          @token_endpoint = nil
          @mutex = Thread::Mutex.new
        end

        ##
        # Returns the OAuth2 token endpoint, fetching the discovery document
        # through the given API client on first access and caching the result.
        #
        # @param api_client [ApiClient] the shared API client used for the discovery request
        # @return [String] the token endpoint URL
        # @raise [ApiError] if discovery fails at the transport or HTTP level
        # @raise [SerializationError] if the discovery document is unusable
        def token_endpoint(api_client)
          @mutex.synchronize do
            @token_endpoint ||= discover(api_client)
          end
        end

        private

        # Validates a host and prefixes +https://+ when it has no scheme.
        #
        # @param host [String, nil] the host name or URL
        # @return [String] the normalised host
        # @raise [ArgumentError] if the host is not a valid http or https URL
        def normalise_host(host)
          trimmed = host.to_s.strip
          raise ArgumentError, 'Host cannot be empty.' if trimmed.empty?

          unless trimmed.downcase.start_with?('http://', 'https://')
            raise ArgumentError, "Host must use the http or https scheme: #{trimmed}" if trimmed.include?('://')

            trimmed = "https://#{trimmed}"
          end
          validate_host(trimmed)
        end

        # @return [String] the host, when it parses and names a host
        # @raise [ArgumentError] otherwise
        def validate_host(host)
          parsed = URI.parse(host)
          raise ArgumentError, "Host is not a valid URL: #{host}" if parsed.host.nil? || parsed.host.empty?

          host
        rescue URI::InvalidURIError => e
          raise ArgumentError, "Host is not a valid URL: #{host}", cause: e
        end

        def discover(api_client)
          url = @well_known_url
          response = api_client.send_request(:GET, url, { 'Accept' => 'application/json' }, nil)
          status = response.status_code
          unless status >= 200 && status < 300
            raise status_error(status, "OpenID discovery at #{url} failed with status #{status}", response)
          end

          token_endpoint_from(parse_document(response.body, url), url)
        end

        def token_endpoint_from(document, url)
          endpoint = document['token_endpoint']
          return endpoint if endpoint.is_a?(String) && !endpoint.empty?

          raise ::Zitadel::Client::SerializationError, "OpenID configuration at #{url} has no valid token_endpoint"
        end

        def parse_document(body, url)
          document = JSON.parse(body)
          return document if document.is_a?(Hash)

          raise ::Zitadel::Client::SerializationError, "OpenID configuration at #{url} is not a JSON object"
        rescue JSON::ParserError => e
          raise ::Zitadel::Client::SerializationError.new("OpenID configuration at #{url} is not a JSON object", e)
        end

        def status_error(status, message, response)
          options = { message: message, response_body: response.body, response_headers: response.headers }
          error = STATUS_ERRORS[status]
          return error.new(**options) unless error.nil?
          return ::Zitadel::Client::Errors::ClientError.new(status_code: status, **options) if status.between?(400, 499)
          return ::Zitadel::Client::Errors::ServerError.new(status_code: status, **options) if status >= 500

          ::Zitadel::Client::ApiError.new(status_code: status, **options)
        end
      end
    end
  end
end
