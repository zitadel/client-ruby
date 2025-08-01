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
          class SettingsServiceAutoLinkingOption
    AUTO_LINKING_OPTION_UNSPECIFIED = "AUTO_LINKING_OPTION_UNSPECIFIED".freeze
    AUTO_LINKING_OPTION_USERNAME = "AUTO_LINKING_OPTION_USERNAME".freeze
    AUTO_LINKING_OPTION_EMAIL = "AUTO_LINKING_OPTION_EMAIL".freeze

    def self.all_vars
      @all_vars ||= [AUTO_LINKING_OPTION_UNSPECIFIED, AUTO_LINKING_OPTION_USERNAME, AUTO_LINKING_OPTION_EMAIL].freeze
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
      return value if SettingsServiceAutoLinkingOption.all_vars.include?(value)
      raise "Invalid ENUM value #{value} for class #Zitadel::Client::Models::SettingsServiceAutoLinkingOption"
    end
  end

end
