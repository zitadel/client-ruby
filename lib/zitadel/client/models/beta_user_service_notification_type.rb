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
          class BetaUserServiceNotificationType
    NOTIFICATION_TYPE_UNSPECIFIED = "NOTIFICATION_TYPE_Unspecified".freeze
    NOTIFICATION_TYPE_EMAIL = "NOTIFICATION_TYPE_Email".freeze
    NOTIFICATION_TYPE_SMS = "NOTIFICATION_TYPE_SMS".freeze

    def self.all_vars
      @all_vars ||= [NOTIFICATION_TYPE_UNSPECIFIED, NOTIFICATION_TYPE_EMAIL, NOTIFICATION_TYPE_SMS].freeze
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
      return value if BetaUserServiceNotificationType.all_vars.include?(value)
      raise "Invalid ENUM value #{value} for class #Zitadel::Client::Models::BetaUserServiceNotificationType"
    end
  end

end
