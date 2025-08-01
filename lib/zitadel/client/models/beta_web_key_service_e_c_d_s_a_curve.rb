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
          class BetaWebKeyServiceECDSACurve
    ECDSA_CURVE_UNSPECIFIED = "ECDSA_CURVE_UNSPECIFIED".freeze
    ECDSA_CURVE_P256 = "ECDSA_CURVE_P256".freeze
    ECDSA_CURVE_P384 = "ECDSA_CURVE_P384".freeze
    ECDSA_CURVE_P512 = "ECDSA_CURVE_P512".freeze

    def self.all_vars
      @all_vars ||= [ECDSA_CURVE_UNSPECIFIED, ECDSA_CURVE_P256, ECDSA_CURVE_P384, ECDSA_CURVE_P512].freeze
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
      return value if BetaWebKeyServiceECDSACurve.all_vars.include?(value)
      raise "Invalid ENUM value #{value} for class #Zitadel::Client::Models::BetaWebKeyServiceECDSACurve"
    end
  end

end
