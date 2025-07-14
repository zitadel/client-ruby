# frozen_string_literal: true

module Zitadel
  module Client
    # A utility class to handle serialization and deserialization of API models.
    # It converts model objects to hashes and JSON strings back to typed objects.
    class ObjectSerializer
      def serialize(model)
        object_to_hash(model)
      end

      # Deserialize the response body string to the given return type.
      # This is the single entry point for deserialization.
      #
      # @param body [String] The raw JSON string from the HTTP response.
      # @param return_type [Class] The target type (e.g., SuccessModel, 'Array<User>').
      # @return [Object, nil] The deserialized object.
      def deserialize(body, return_type)
        return body if return_type == String

        data = JSON.parse(body, symbolize_names: true)
        convert_to_type(data, return_type)
      end

      private

      # Convert object (array, hash, object, etc.) to JSON string.
      # noinspection RubyMismatchedReturnType,RbsMissingTypeSignature
      # Converts an object to a serializable structure (Hash, Array, primitive).
      # This is the corrected implementation to prevent infinite recursion.
      #
      # @param obj [Object] The object to convert.
      # @return [Object] A hash/array representation or the object itself if it's a primitive.
      def object_to_hash(obj)
        case obj
        when nil, String, Integer, Float, TrueClass, FalseClass, Time, Date
          obj
        when Array
          obj.map { |v| object_to_hash(v) }
        when Hash
          obj.transform_values { |v| object_to_hash(v) }
        else
          obj.to_hash
        end
      end

      # Convert data to the given return type.
      # @param [Object] data Data to be converted
      # @param [Class] return_type Return type
      # @return [Mixed] Data in a particular type
      # noinspection RubyArgCount,RubyMismatchedArgumentType,RbsMissingTypeSignature
      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
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
          klass = return_type
          klass.respond_to?(:openapi_one_of) ? klass.build(data) : klass.build_from_hash(data)
        end
        # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
      end
    end
  end
end
