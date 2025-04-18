# frozen_string_literal: true

# rubocop:disable Style/ClassVars
# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/PerceivedComplexity
# rubocop:disable Metrics/ClassLength

require 'date'
require 'json'
require 'logger'
require 'tempfile'
require 'time'
require 'typhoeus'
require 'uri'

module ZitadelClient
  # ApiClient handles all HTTP interactions with the Zitadel API.
  #
  # It is responsible for:
  # - Constructing and signing requests via the configured authenticator
  # - Executing HTTP calls and handling errors (timeouts, non-2xx responses)
  # - Streaming file downloads into temporary files
  # - Deserializing JSON responses into Ruby types and model objects
  #
  # === Usage Example:
  #   config = ZitadelClient::Configuration.new do |c|
  #     c.authenticator = ZitadelClient::ClientCredentialsAuthenticator.builder(base_url, id, secret).build
  #   end
  #   client = ZitadelClient::ApiClient.new(config)
  #   data, status, headers = client.call_api(:get, '/users', query_params: { limit: 10 })
  class ApiClient
    # The Configuration object holding settings to be used in the API client.
    attr_accessor :config

    # Defines the headers to be used in HTTP requests of all API calls by default.
    #
    # @return [Hash[String, String]]
    attr_accessor :default_headers

    # Initializes the ApiClient
    # @option config [Configuration] Configuration for initializing the object, default to the
    # default configuration.
    def initialize(config = Configuration.new)
      @config = config
      @default_headers = {
        'Content-Type' => 'application/json',
        'User-Agent' => config.user_agent
      }
    end

    # noinspection RubyClassVariableUsageInspection,RbsMissingTypeSignature
    # @return [ZitadelClient::ApiClient]
    def self.default
      @@default ||= ApiClient.new
    end

    # Call an API with given options.
    #
    # @return [Array<(Object, Integer, Hash)>] an array of 3 elements:
    #   the data deserialized from response body (which may be a Tempfile or nil), response status code and response headers.
    # noinspection RbsMissingTypeSignature
    def call_api(http_method, path, opts = {})
      request = build_request(http_method, path, opts)
      tempfile = nil
      (download_file(request) { tempfile = _1 }) if opts[:return_type] == 'File'
      response = request.run

      @config.logger.debug "HTTP response body ~BEGIN~\n#{response.body}\n~END~\n" if @config.debugging

      unless response.success?
        if response.timed_out?
          raise ApiError, 'Connection timed out'
        elsif response.code.zero?
          # Errors from libcurl will be made visible here
          raise ApiError.new(code: 0,
                             message: response.return_message)
        else
          raise ApiError.new(code: response.code,
                             response_headers: response.headers,
                             response_body: response.body),
                response.status_message
        end
      end

      data = if opts[:return_type] == 'File'
               tempfile
             elsif opts[:return_type]
               deserialize(response, opts[:return_type])
             end
      [data, response.code, response.headers]
    end

    # Builds the HTTP request
    #
    # @param [String] http_method HTTP method/verb (e.g. POST)
    # @param [String] path URL path (e.g. /account/new)
    # @option opts [Hash] :header_params Header parameters
    # @option opts [Hash] :query_params Query parameters
    # @option opts [Hash] :form_params Query parameters
    # @option opts [Object] :body HTTP body (JSON/XML)
    # @return [Typhoeus::Request] A Typhoeus Request
    # noinspection RbsMissingTypeSignature
    def build_request(http_method, path, opts = {})
      url = URI.join("#{@config.authenticator.send(:host).chomp('/')}/", path).to_s
      http_method = http_method.to_sym.downcase

      query_params = opts[:query_params] || {}
      form_params = opts[:form_params] || {}
      follow_location = opts[:follow_location] || true
      header_params = @default_headers.merge(opts[:header_params] || {}).merge(@config.authenticator.send(:auth_headers))

      req_opts = {
        method: http_method,
        headers: header_params,
        params: query_params,
        params_encoding: @config.params_encoding,
        timeout: @config.timeout,
        ssl_verifypeer: @config.verify_ssl,
        ssl_verifyhost: (@config.verify_ssl_host ? 2 : 0),
        sslcert: @config.cert_file,
        sslkey: @config.key_file,
        verbose: @config.debugging,
        followlocation: follow_location
      }

      # set custom cert, if provided
      req_opts[:cainfo] = @config.ssl_ca_cert if @config.ssl_ca_cert

      if %i[post patch put delete].include?(http_method)
        req_body = build_request_body(header_params, form_params, opts[:body])
        req_opts.update body: req_body
        @config.logger.debug "HTTP request body param ~BEGIN~\n#{req_body}\n~END~\n" if @config.debugging
      end

      Typhoeus::Request.new(url, req_opts)
    end

    # Builds the HTTP request body
    #
    # @param [Hash] header_params Header parameters
    # @param [Hash] form_params Query parameters
    # @param [Object] body HTTP body (JSON/XML)
    # @return [String] HTTP body data in the form of string
    # noinspection RubyMismatchedReturnType,RubyArgCount,RbsMissingTypeSignature
    def build_request_body(header_params, form_params, body)
      # http form
      if ['application/x-www-form-urlencoded',
          'multipart/form-data'].include?(header_params['Content-Type'])
        data = {}
        form_params.each do |key, value|
          data[key] = case value
                      when ::File, ::Array, nil
                        # let typhoeus handle File, Array and nil parameters
                        value
                      else
                        value.to_s
                      end
        end
      elsif body
        data = body.is_a?(String) ? body : body.to_json
      else
        data = nil
      end
      data
    end

    # Save response body into a file in (the defined) temporary folder, using the filename
    # from the "Content-Disposition" header if provided, otherwise a random filename.
    # The response body is written to the file in chunks in order to handle files which
    # size is larger than maximum Ruby String or even larger than the maximum memory a Ruby
    # process can use.
    #
    # @see Configuration#temp_folder_path
    #
    # @return [Tempfile] the tempfile generated
    # noinspection RbsMissingTypeSignature
    def download_file(request)
      tempfile = nil
      encoding = nil

      request.on_headers do |response|
        content_disposition = response.headers['Content-Disposition']
        if content_disposition && content_disposition =~ /filename=/i
          filename = content_disposition[/filename=['"]?([^'"\s]+)['"]?/, 1]
          prefix = sanitize_filename(filename)
        else
          prefix = 'download-'
        end
        prefix += '-' unless prefix.end_with?('-')
        encoding = response.body.encoding
        tempfile = Tempfile.open(prefix, @config.temp_folder_path, encoding: encoding)
      end

      request.on_body do |chunk|
        chunk.force_encoding(encoding) if encoding
        ensure_tempfile(tempfile).write(chunk)
      end

      request.on_complete do
        t = ensure_tempfile(tempfile)
        t.close
        @config.logger.info "Temp file written to #{t.path}, please copy the file to a proper folder " \
                            "with e.g. `FileUtils.cp(t.path, '/new/file/path')` otherwise the temp file " \
                            "will be deleted automatically with GC. It's also recommended to delete the temp file " \
                            'explicitly with `t.delete`'
        yield t if block_given?
      end
    end

    def ensure_tempfile(temp)
      temp || (raise 'Tempfile not created')
    end

    # Check if the given MIME is a JSON MIME.
    # JSON MIME examples:
    #   application/json
    #   application/json; charset=UTF8
    #   APPLICATION/JSON
    #   */*
    # @param [String] mime MIME
    # @return [Boolean] True if the MIME is application/json
    # noinspection RbsMissingTypeSignature
    def json_mime?(mime)
      (mime == '*/*') || !(mime =~ %r{^Application/.*json(?!p)(;.*)?}i).nil?
    end

    # Deserialize the response to the given return type.
    #
    # @param [Response] response HTTP response
    # @param [String] return_type some examples: "User", "Array<User>", "Hash<String, Integer>"
    # noinspection RbsMissingTypeSignature
    def deserialize(response, return_type)
      body = response.body
      return nil if body.nil? || body.empty?

      # return response body directly for String return type
      return body.to_s if return_type == 'String'

      # ensuring a default content type
      content_type = response.headers['Content-Type'] || 'application/json'

      raise "Content-Type is not supported: #{content_type}" unless json_mime?(content_type)

      begin
        data = JSON.parse("[#{body}]", symbolize_names: true)[0]
      rescue JSON::ParserError => e
        raise e unless %w[String Date Time].include?(return_type)

        data = body
      end

      convert_to_type data, return_type
    end

    # Convert data to the given return type.
    # @param [Object] data Data to be converted
    # @param [String] return_type Return type
    # @return [Mixed] Data in a particular type
    # noinspection RubyArgCount,RubyMismatchedArgumentType,RbsMissingTypeSignature
    def convert_to_type(data, return_type)
      return nil if data.nil?

      # noinspection RegExpRedundantEscape
      case return_type
      when 'String'
        data.to_s
      when 'Integer'
        data.to_i
      when 'Float'
        data.to_f
      when 'Boolean'
        data == true
      when 'Time'
        # parse date time (expecting ISO 8601 format)
        Time.parse data
      when 'Date'
        # parse date time (expecting ISO 8601 format)
        Date.parse data
      when 'Object'
        # generic object (usually a Hash), return directly
        data
      when /\AArray<(.+)>\z/
        # e.g. Array<Pet>
        sub_type = ::Regexp.last_match(1)
        data.map { |item| convert_to_type(item, sub_type) }
      when /\AHash<String, (.+)>\z/
        # e.g. Hash<String, Integer>
        sub_type = ::Regexp.last_match(1)
        {}.tap do |hash|
          data.each { |k, v| hash[k] = convert_to_type(v, sub_type) }
        end
      else
        # models (e.g. Pet) or oneOf
        klass = ZitadelClient.const_get(return_type)
        klass.respond_to?(:openapi_one_of) ? klass.build(data) : klass.build_from_hash(data)
      end
    end

    # Sanitize filename by removing path.
    # e.g. ../../sun.gif becomes sun.gif
    #
    # @param [String] filename the filename to be sanitized
    # @return [String] the sanitized filename
    # noinspection RubyMismatchedReturnType,RbsMissingTypeSignature
    def sanitize_filename(filename)
      filename.split(%r{[/\\]}).last
    end

    # Return Accept header based on an array of accepts provided.
    # @param [Array] accepts array for Accept
    # @return [String] the Accept header (e.g. application/json)
    # noinspection RubyArgCount,RbsMissingTypeSignature
    def select_header_accept(accepts)
      return nil if accepts.nil? || accepts.empty?

      # use JSON when present, otherwise use all the provided
      json_accept = accepts.find { |s| json_mime?(s) }
      json_accept || accepts.join(',')
    end

    # Return Content-Type header based on an array of content types provided.
    # @param [Array] content_types array for Content-Type
    # @return [String] the Content-Type header  (e.g. application/json)
    # noinspection RubyArgCount,RbsMissingTypeSignature
    def select_header_content_type(content_types)
      # return nil by default
      return if content_types.nil? || content_types.empty?

      # use JSON when present, otherwise use the first one
      json_content_type = content_types.find { |s| json_mime?(s) }
      json_content_type || content_types.first
    end

    # Convert object (array, hash, object, etc.) to JSON string.
    # @param [Object] model object to be converted into JSON string
    # @return [String] JSON string representation of the object
    # noinspection RubyMismatchedReturnType,RbsMissingTypeSignature
    def object_to_http_body(model)
      return model if model.nil? || model.is_a?(String)

      local_body = if model.is_a?(Array)
                     model.map { |m| object_to_hash(m) }
                   else
                     object_to_hash(model)
                   end
      local_body.to_json
    end

    # Convert object(non-array) to hash.
    # @param [Object] obj object to be converted into JSON string
    # @return [String] JSON string representation of the object
    # noinspection RubyMismatchedReturnType,RbsMissingTypeSignature
    def object_to_hash(obj)
      if obj.respond_to?(:to_hash)
        obj.to_hash
      else
        obj
      end
    end

    # Build parameter value according to the given collection format.
    # @param [String] collection_format one of :csv, :ssv, :tsv, :pipes and :multi
    # noinspection RbsMissingTypeSignature
    def build_collection_param(param, collection_format)
      case collection_format
      when :csv
        param.join(',')
      when :ssv
        param.join(' ')
      when :tsv
        param.join("\t")
      when :pipes
        param.join('|')
      when :multi
        # return the array directly as typhoeus will handle it as expected
        param
      else
        raise "unknown collection format: #{collection_format.inspect}"
      end
    end
  end
end

# rubocop:enable Style/ClassVars
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/CyclomaticComplexity
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/PerceivedComplexity
# rubocop:enable Metrics/ClassLength
