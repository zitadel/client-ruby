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
          class SAMLServiceErrorReason
    ERROR_REASON_UNSPECIFIED = "ERROR_REASON_UNSPECIFIED".freeze
    ERROR_REASON_VERSION_MISSMATCH = "ERROR_REASON_VERSION_MISSMATCH".freeze
    ERROR_REASON_AUTH_N_FAILED = "ERROR_REASON_AUTH_N_FAILED".freeze
    ERROR_REASON_INVALID_ATTR_NAME_OR_VALUE = "ERROR_REASON_INVALID_ATTR_NAME_OR_VALUE".freeze
    ERROR_REASON_INVALID_NAMEID_POLICY = "ERROR_REASON_INVALID_NAMEID_POLICY".freeze
    ERROR_REASON_REQUEST_DENIED = "ERROR_REASON_REQUEST_DENIED".freeze
    ERROR_REASON_REQUEST_UNSUPPORTED = "ERROR_REASON_REQUEST_UNSUPPORTED".freeze
    ERROR_REASON_UNSUPPORTED_BINDING = "ERROR_REASON_UNSUPPORTED_BINDING".freeze

    def self.all_vars
      @all_vars ||= [ERROR_REASON_UNSPECIFIED, ERROR_REASON_VERSION_MISSMATCH, ERROR_REASON_AUTH_N_FAILED, ERROR_REASON_INVALID_ATTR_NAME_OR_VALUE, ERROR_REASON_INVALID_NAMEID_POLICY, ERROR_REASON_REQUEST_DENIED, ERROR_REASON_REQUEST_UNSUPPORTED, ERROR_REASON_UNSUPPORTED_BINDING].freeze
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
      return value if SAMLServiceErrorReason.all_vars.include?(value)
      raise "Invalid ENUM value #{value} for class #Zitadel::Client::Models::SAMLServiceErrorReason"
    end
  end

end
