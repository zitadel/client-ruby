# frozen_string_literal: true

# noinspection RubyResolve
require 'test_helper'
require 'minitest/autorun'
require 'json'
require 'date'
require 'time'
require 'bigdecimal'
require 'ipaddr'
require 'uri'
require 'set'
require 'json_expressions/minitest'

module Zitadel
  module Client
    # rubocop:disable Style/ConditionalAssignment, Metrics/MethodLength
    module Models
      class NestedObject < BaseModel
        attr_accessor :some_level1

        def self.attribute_map
          {
            some_level1: :some_level1
          }
        end

        def self.openapi_types
          {
            some_level1: :Level1
          }
        end

        def self.openapi_nullable
          Set.new
        end

        def initialize(attributes = {})
          super()
          unless attributes.is_a?(Hash)
            raise ArgumentError,
                  "The input argument (attributes) must be a hash in `#{self.class}` initialize method"
          end

          # ensure only known keys are allowed
          acceptable_attribute_map = self.class.attribute_map
          attributes = attributes.each_with_object({}) do |(k, v), h|
            unless acceptable_attribute_map.key?(k.to_sym)
              raise ArgumentError,
                    "`#{k}` is not a valid attribute in `#{self.class}`. " \
                    "List of attributes: #{acceptable_attribute_map.keys.inspect}"
            end
            h[k.to_sym] = v
          end

          return unless attributes.key?(:some_level1)

          self.some_level1 = attributes[:some_level1]
        end
      end

      class Level1 < BaseModel
        attr_accessor :some_level2

        def self.attribute_map
          {
            some_level2: :some_level2
          }
        end

        def self.openapi_types
          {
            some_level2: :Level2
          }
        end

        def self.openapi_nullable
          Set.new
        end

        def initialize(attributes = {})
          super()
          unless attributes.is_a?(Hash)
            raise ArgumentError,
                  'The input argument (attributes) must be a hash in `Zitadel::Client::Models::SerdeModel::NestedObject::Level1` initialize method'
          end

          acceptable = self.class.attribute_map
          attributes = attributes.each_with_object({}) do |(k, v), h|
            unless acceptable.key?(k.to_sym)
              raise ArgumentError,
                    "`#{k}` is not a valid attribute in `Zitadel::Client::Models::SerdeModel::NestedObject::Level1`. List of attributes: #{acceptable.keys.inspect}"
            end

            h[k.to_sym] = v
          end

          return unless attributes.key?(:some_level2)

          self.some_level2 = attributes[:some_level2]
        end
      end

      class Level2 < BaseModel
        attr_accessor :some_level3_string, :some_level3_number

        def self.attribute_map
          {
            some_level3_string: :some_level3_string,
            some_level3_number: :some_level3_number
          }
        end

        def self.openapi_types
          {
            some_level3_string: :String,
            some_level3_number: :Float
          }
        end

        def self.openapi_nullable
          Set.new
        end

        def initialize(attributes = {})
          super()
          unless attributes.is_a?(Hash)
            raise ArgumentError,
                  'The input argument (attributes) must be a hash in `Zitadel::Client::Models::SerdeModel::NestedObject::Level1::Level2` initialize method'
          end

          acceptable = self.class.attribute_map
          attributes = attributes.each_with_object({}) do |(k, v), h|
            unless acceptable.key?(k.to_sym)
              raise ArgumentError,
                    "`#{k}` is not a valid attribute in `Zitadel::Client::Models::SerdeModel::NestedObject::Level1::Level2`. List of attributes: #{acceptable.keys.inspect}"
            end

            h[k.to_sym] = v
          end

          self.some_level3_string = attributes[:some_level3_string] if attributes.key?(:some_level3_string)

          return unless attributes.key?(:some_level3_number)

          self.some_level3_number = attributes[:some_level3_number].to_f
        end
      end

      class Item < BaseModel
        attr_accessor :some_id, :some_name

        def self.attribute_map
          {
            some_id: :some_id,
            some_name: :some_name
          }
        end

        def self.openapi_types
          {
            some_id: :Integer,
            some_name: :String
          }
        end

        def self.openapi_nullable
          Set.new
        end

        def initialize(attributes = {})
          super()
          unless attributes.is_a?(Hash)
            raise ArgumentError,
                  'The input argument (attributes) must be a hash in `Zitadel::Client::Models::SerdeModel::Item` initialize method'
          end

          acceptable = self.class.attribute_map
          attributes = attributes.each_with_object({}) do |(k, v), h|
            unless acceptable.key?(k.to_sym)
              raise ArgumentError,
                    "`#{k}` is not a valid attribute in `Zitadel::Client::Models::SerdeModel::Item`. List of attributes: #{acceptable.keys.inspect}"
            end

            h[k.to_sym] = v
          end

          self.some_id = attributes[:some_id].to_i if attributes.key?(:some_id)

          return unless attributes.key?(:some_name)

          self.some_name = attributes[:some_name]
        end
      end

      class SerdeModel < BaseModel
        attr_accessor :some_string, :some_binary, :some_byte,
                      :some_date, :some_date_time, :some_password,
                      :some_email, :some_hostname, :some_ipv4,
                      :some_ipv6, :some_uri, :some_uri_reference,
                      :some_uri_template, :some_json_pointer,
                      :some_relative_json_pointer, :some_regex,
                      :some_number, :some_float, :some_double,
                      :some_integer, :some_int32, :some_int64,
                      :some_boolean, :some_array, :some_object,
                      :some_nested_object, :some_array_of_objects,
                      :some_nullable_field

        def self.attribute_map
          {
            some_string: :some_string,
            some_binary: :some_binary,
            some_byte: :some_byte,
            some_date: :some_date,
            some_date_time: :some_date_time,
            some_password: :some_password,
            some_email: :some_email,
            some_hostname: :some_hostname,
            some_ipv4: :some_ipv4,
            some_ipv6: :some_ipv6,
            some_uri: :some_uri,
            some_uri_reference: :some_uri_reference,
            some_uri_template: :some_uri_template,
            some_json_pointer: :some_json_pointer,
            some_relative_json_pointer: :some_relative_json_pointer,
            some_regex: :some_regex,
            some_number: :some_number,
            some_float: :some_float,
            some_double: :some_double,
            some_integer: :some_integer,
            some_int32: :some_int32,
            some_int64: :some_int64,
            some_boolean: :some_boolean,
            some_array: :some_array,
            some_object: :some_object,
            some_nested_object: :some_nested_object,
            some_array_of_objects: :some_array_of_objects,
            some_nullable_field: :some_nullable_field
          }
        end

        def self.openapi_types
          {
            some_string: :String,
            some_binary: :String,
            some_byte: :String,
            some_date: :Date,
            some_date_time: :Time,
            some_password: :String,
            some_email: :String,
            some_hostname: :String,
            some_ipv4: :IPAddr,
            some_ipv6: :IPAddr,
            some_uri: :URI,
            some_uri_reference: :String,
            some_uri_template: :String,
            some_json_pointer: :String,
            some_relative_json_pointer: :String,
            some_regex: :String,
            some_number: :Float,
            some_float: :Float,
            some_double: :Float,
            some_integer: :Integer,
            some_int32: :Integer,
            some_int64: :Integer,
            some_boolean: :Boolean,
            some_array: :'Array<String>',
            some_object: :'Hash<String, Object>',
            some_nested_object: :NestedObject,
            some_array_of_objects: :'Array<Item>',
            some_nullable_field: :Object
          }
        end

        def self.openapi_nullable
          Set.new([:some_nullable_field])
        end

        def initialize(attributes = {})
          super()
          unless attributes.is_a?(Hash)
            raise ArgumentError,
                  'The input argument (attributes) must be a hash in `Zitadel::Client::Models::SerdeModel` initialize method'
          end

          # check to see if the attribute exists and convert string to symbol for hash key
          acceptable = self.class.attribute_map # your attribute_map covers acceptable keys
          attributes = attributes.each_with_object({}) do |(k, v), h|
            unless acceptable.key?(k.to_sym)
              raise ArgumentError,
                    "`#{k}` is not a valid attribute in `Zitadel::Client::Models::SerdeModel`. " \
                    "List of attributes: #{acceptable.keys.inspect}"
            end
            h[k.to_sym] = v
          end

          if attributes.key?(:some_string)
            self.some_string = attributes[:some_string]
          else
            self.some_string = nil
          end

          if attributes.key?(:some_binary)
            self.some_binary = attributes[:some_binary]
          else
            self.some_binary = nil
          end

          if attributes.key?(:some_byte)
            self.some_byte = attributes[:some_byte]
          else
            self.some_byte = nil
          end

          if attributes.key?(:some_date)
            self.some_date = attributes[:some_date]
          else
            self.some_date = nil
          end

          if attributes.key?(:some_date_time)
            self.some_date_time = attributes[:some_date_time]
          else
            self.some_date_time = nil
          end

          if attributes.key?(:some_password)
            self.some_password = attributes[:some_password]
          else
            self.some_password = nil
          end

          if attributes.key?(:some_email)
            self.some_email = attributes[:some_email]
          else
            self.some_email = nil
          end

          if attributes.key?(:some_hostname)
            self.some_hostname = attributes[:some_hostname]
          else
            self.some_hostname = nil
          end

          if attributes.key?(:some_ipv4)
            self.some_ipv4 = attributes[:some_ipv4]
          else
            self.some_ipv4 = nil
          end

          if attributes.key?(:some_ipv6)
            self.some_ipv6 = attributes[:some_ipv6]
          else
            self.some_ipv6 = nil
          end

          if attributes.key?(:some_uri)
            self.some_uri = attributes[:some_uri]
          else
            self.some_uri = nil
          end

          if attributes.key?(:some_uri_reference)
            self.some_uri_reference = attributes[:some_uri_reference]
          else
            self.some_uri_reference = nil
          end

          if attributes.key?(:some_uri_template)
            self.some_uri_template = attributes[:some_uri_template]
          else
            self.some_uri_template = nil
          end

          if attributes.key?(:some_json_pointer)
            self.some_json_pointer = attributes[:some_json_pointer]
          else
            self.some_json_pointer = nil
          end

          if attributes.key?(:some_relative_json_pointer)
            self.some_relative_json_pointer = attributes[:some_relative_json_pointer]
          else
            self.some_relative_json_pointer = nil
          end

          if attributes.key?(:some_regex)
            self.some_regex = attributes[:some_regex]
          else
            self.some_regex = nil
          end

          if attributes.key?(:some_number)
            self.some_number = attributes[:some_number]
          else
            self.some_number = nil
          end

          if attributes.key?(:some_float)
            self.some_float = attributes[:some_float]
          else
            self.some_float = nil
          end

          if attributes.key?(:some_double)
            self.some_double = attributes[:some_double]
          else
            self.some_double = nil
          end

          if attributes.key?(:some_integer)
            self.some_integer = attributes[:some_integer]
          else
            self.some_integer = nil
          end

          if attributes.key?(:some_int32)
            self.some_int32 = attributes[:some_int32]
          else
            self.some_int32 = nil
          end

          if attributes.key?(:some_int64)
            self.some_int64 = attributes[:some_int64]
          else
            self.some_int64 = nil
          end

          if attributes.key?(:some_boolean)
            self.some_boolean = attributes[:some_boolean]
          else
            self.some_boolean = nil
          end

          if attributes.key?(:some_array)
            self.some_array = attributes[:some_array].map { |v| v }
          else
            self.some_array = nil
          end

          if attributes.key?(:some_object)
            self.some_object = attributes[:some_object]
          else
            self.some_object = nil
          end

          if attributes.key?(:some_nested_object)
            self.some_nested_object = attributes[:some_nested_object]
          else
            self.some_nested_object = nil
          end

          if attributes.key?(:some_array_of_objects)
            self.some_array_of_objects = attributes[:some_array_of_objects]
          else
            self.some_array_of_objects = nil
          end

          if attributes.key?(:some_nullable_field)
            self.some_nullable_field = attributes[:some_nullable_field]
          else
            self.some_nullable_field = nil
          end
        end
      end
    end
    # rubocop:enable Style/ConditionalAssignment, Metrics/MethodLength

    class ObjectSerializerTest < Minitest::Test
      SERIALIZER = ObjectSerializer.new

      def test_round_trip
        raw = File.read(File.join(File.dirname(__FILE__), 'resources', 'serde.json'))
        model = SERIALIZER.deserialize(raw, Models::SerdeModel)
        out = SERIALIZER.serialize(model)

        ox = JSON.parse(out.to_json)
        ox.delete('some_nullable_field')

        assert_json_match JSON.parse(raw), ox
      end
    end
  end
end
