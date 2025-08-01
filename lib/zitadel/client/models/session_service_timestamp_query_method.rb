=begin
#Zitadel SDK

#The Zitadel SDK is a convenience wrapper around the Zitadel APIs to assist you in integrating with your Zitadel environment. This SDK enables you to handle resources, settings, and configurations within the Zitadel platform.

The version of the OpenAPI document: 1.0.0

Generated by: https://openapi-generator.tech
Generator version: 7.13.0

=end

require 'date'
require 'time'

module Zitadel::Client::Models
          class SessionServiceTimestampQueryMethod
    TIMESTAMP_QUERY_METHOD_EQUALS = "TIMESTAMP_QUERY_METHOD_EQUALS".freeze
    TIMESTAMP_QUERY_METHOD_GREATER = "TIMESTAMP_QUERY_METHOD_GREATER".freeze
    TIMESTAMP_QUERY_METHOD_GREATER_OR_EQUALS = "TIMESTAMP_QUERY_METHOD_GREATER_OR_EQUALS".freeze
    TIMESTAMP_QUERY_METHOD_LESS = "TIMESTAMP_QUERY_METHOD_LESS".freeze
    TIMESTAMP_QUERY_METHOD_LESS_OR_EQUALS = "TIMESTAMP_QUERY_METHOD_LESS_OR_EQUALS".freeze

    def self.all_vars
      @all_vars ||= [TIMESTAMP_QUERY_METHOD_EQUALS, TIMESTAMP_QUERY_METHOD_GREATER, TIMESTAMP_QUERY_METHOD_GREATER_OR_EQUALS, TIMESTAMP_QUERY_METHOD_LESS, TIMESTAMP_QUERY_METHOD_LESS_OR_EQUALS].freeze
    end

    # Builds the enum from string
    # @param [String] The enum value in the form of the string
    # @return [String] The enum value
    def self.build_from_hash(value)
      new.build_from_hash(value)
    end

    # Builds the enum from string
    # @param [String] The enum value in the form of the string
    # @return [String] The enum value
    def build_from_hash(value)
      return value if SessionServiceTimestampQueryMethod.all_vars.include?(value)
      raise "Invalid ENUM value #{value} for class #Zitadel::Client::Models::SessionServiceTimestampQueryMethod"
    end
  end

end
