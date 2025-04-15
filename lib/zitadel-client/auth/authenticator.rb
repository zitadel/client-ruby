# frozen_string_literal: true

require 'time'
require 'set'

module ZitadelClient
  ##
  # Abstract base class for authenticators.
  #
  # This class defines the basic structure for any authenticator by requiring the implementation
  # of a method to retrieve authentication headers, and provides a way to store and retrieve the host.
  #
  class Authenticator
    protected

    def host
      @host
    end

    ##
    # Initializes the Authenticator with the specified host.
    #
    # @param host [String] the base URL or endpoint for the service.
    #
    def initialize(host)
      @host = host
    end

    ##
    # Retrieves the authentication headers to be sent with requests.
    #
    # Subclasses must override this method to return the appropriate headers.
    #
    # @raise [NotImplementedError] Always raised to require implementation in a subclass.
    #
    # @return [Hash{String => String}]
    #
    def get_auth_headers
      raise NotImplementedError, "#{self.class}#get_auth_headers is an abstract method. Please override it in a subclass."
    end
  end

  ##
  # Abstract builder class for constructing OAuth authenticator instances.
  #
  # This builder provides common configuration options such as the OpenId instance and authentication scopes.
  #
  class OAuthAuthenticatorBuilder
    protected

    def open_id
      @open_id
    end

    def auth_scopes
      @auth_scopes
    end

    ##
    # Initializes the OAuthAuthenticatorBuilder with a given host.
    #
    # @param host [String] the base URL for the OAuth provider.
    #
    def initialize(host)
      @open_id = OpenId.new(host)
      @auth_scopes = Set.new(%w[openid urn:zitadel:iam:org:project:id:zitadel:aud])
    end

    public

    ##
    # Sets the authentication scopes for the OAuth authenticator.
    #
    # @param scopes [Array<String>] a variable number of scope strings.
    # @return [self] the builder instance to allow for method chaining.
    #
    def scopes(*scopes)
      @auth_scopes = Set.new(scopes)
      self
    end
  end
end
