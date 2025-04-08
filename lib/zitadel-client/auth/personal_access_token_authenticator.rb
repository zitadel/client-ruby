# frozen_string_literal: true

##
# Personal Access Token Authenticator.
#
# Uses a static personal access token for API authentication.
#
class PersonalAccessTokenAuthenticator < Authenticator
  ##
  # Initializes the PersonalAccessTokenAuthenticator with host and token.
  #
  # @param host [String] the base URL for the service.
  # @param token [String] the personal access token.
  #
  def initialize(host, token)
    # noinspection RubyArgCount
    super(URLUtil.build_hostname(host))
    @token = token
  end

  ##
  # Returns the authentication headers using the personal access token.
  #
  # @return [Hash{String => String}] a hash containing the 'Authorization' header.
  #
  def get_auth_headers
    { "Authorization" => "Bearer " + @token }
  end
end
