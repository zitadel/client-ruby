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
          class OIDCServicePrompt
    PROMPT_UNSPECIFIED = "PROMPT_UNSPECIFIED".freeze
    PROMPT_NONE = "PROMPT_NONE".freeze
    PROMPT_LOGIN = "PROMPT_LOGIN".freeze
    PROMPT_CONSENT = "PROMPT_CONSENT".freeze
    PROMPT_SELECT_ACCOUNT = "PROMPT_SELECT_ACCOUNT".freeze
    PROMPT_CREATE = "PROMPT_CREATE".freeze

    def self.all_vars
      @all_vars ||= [PROMPT_UNSPECIFIED, PROMPT_NONE, PROMPT_LOGIN, PROMPT_CONSENT, PROMPT_SELECT_ACCOUNT, PROMPT_CREATE].freeze
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
      return value if OIDCServicePrompt.all_vars.include?(value)
      raise "Invalid ENUM value #{value} for class #Zitadel::Client::Models::OIDCServicePrompt"
    end
  end

end
