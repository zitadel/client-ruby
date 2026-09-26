# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../spec_helper'
require_relative '../base_spec'

# SettingsService Integration Tests (Personal Access Token)
#
# This suite verifies the Zitadel SettingsService API's general settings
# endpoint works when authenticating via a Personal Access Token:
#
#  1. Retrieve general settings successfully with a valid token
#  2. Expect an UnauthorizedError when using an invalid token
#
# Each test runs in isolation: the client is instantiated in each example to
# guarantee a clean, stateless call.
class UseAccessTokenSpec < BaseSpec
  it 'retrieves general settings with valid token' do
    authenticator = Zitadel::Client::Auth::PersonalAccessTokenAuthenticator.new(@base_url, @auth_token)
    client = Zitadel::Client::Zitadel.with_authenticator(authenticator)
    client.settings_service.get_general_settings({})
  end

  it 'raises an UnauthorizedError with invalid token' do
    authenticator = Zitadel::Client::Auth::PersonalAccessTokenAuthenticator.new(@base_url, 'invalid')
    client = Zitadel::Client::Zitadel.with_authenticator(authenticator)
    error = assert_raises(Zitadel::Client::Errors::UnauthorizedError) do
      client.settings_service.get_general_settings({})
    end
    assert_instance_of Zitadel::Client::Errors::UnauthorizedError, error
  end
end
