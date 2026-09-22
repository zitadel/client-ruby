# frozen_string_literal: true

module Zitadel
  module Client
    module Auth
      ##
      # Abstract builder for OAuth authenticators.
      #
      # Holds the OpenID discovery helper for the host and the requested scopes.
      class OAuthAuthenticatorBuilder
        # The default scopes requested when none are configured.
        DEFAULT_SCOPE = 'openid urn:zitadel:iam:org:project:id:zitadel:aud'

        # @return [OpenId] the OpenID discovery helper for the host
        attr_reader :open_id
        # @return [String] the space-delimited scope string for the token request
        attr_reader :scope

        ##
        # @param host [String] the base URL for the OAuth provider
        # @raise [ArgumentError] if the host is not a valid http or https URL
        def initialize(host)
          @open_id = OpenId.new(host)
          @scope = DEFAULT_SCOPE
        end

        ##
        # Overrides the default scopes. Duplicates are dropped; order is kept.
        #
        # @param auth_scopes [Array<String>] the scopes for the token request
        # @return [self] the builder
        # @raise [ArgumentError] if no scope is given, or a scope is empty or contains whitespace
        def scopes(*auth_scopes)
          raise ArgumentError, 'At least one scope is required.' if auth_scopes.empty?

          auth_scopes.each do |auth_scope|
            next if auth_scope.is_a?(String) && !auth_scope.empty? && !auth_scope.match?(/\s/)

            raise ArgumentError, "Scope must be a non-empty string without whitespace: '#{auth_scope}'"
          end
          @scope = auth_scopes.uniq.join(' ')
          self
        end

        # Raises ArgumentError when the value is nil or blank.
        #
        # @param value [String, nil] the value to check
        # @param label [String] the name used in the error message
        # @return [String] the value
        def self.require_text(value, label)
          raise ArgumentError, "#{label} cannot be empty." unless value.is_a?(String) && !value.strip.empty?

          value
        end
      end
    end
  end
end
