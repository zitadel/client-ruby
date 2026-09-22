# frozen_string_literal: true

module Zitadel
  module Client
    module Auth
      # Abstract builder for constructing OAuth authenticator instances.
      #
      # Provides common configuration: the resolved {OpenId} instance (fetched
      # eagerly via OpenID discovery using the supplied transport options) and
      # the authentication scopes.
      class OAuthAuthenticatorBuilder
        DEFAULT_SCOPES = %w[openid urn:zitadel:iam:org:project:id:zitadel:aud].freeze

        # @return [OpenId]
        attr_reader :open_id

        # @return [Set<String>]
        attr_reader :auth_scopes

        # @return [TransportOptions]
        attr_reader :transport_options

        # @param host [String] The base URL for the OAuth provider.
        # @param transport_options [TransportOptions, nil] Optional transport options for TLS, proxy, and headers.
        def initialize(host, transport_options: nil)
          @transport_options = transport_options || TransportOptions.builder.build
          @open_id = OpenId.new(host, transport_options: @transport_options)
          @auth_scopes = DEFAULT_SCOPES.to_set
        end

        # Sets the authentication scopes for the OAuth authenticator.
        #
        # @param auth_scopes [Array<String>] scope strings.
        # @return [self]
        def scopes(*auth_scopes)
          @auth_scopes = auth_scopes.to_set
          self
        end
      end
    end
  end
end
