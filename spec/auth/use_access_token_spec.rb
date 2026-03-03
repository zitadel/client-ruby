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
#  2. Expect an ApiError when using an invalid token
#
# Each test runs in isolation: the client is instantiated in each example to
# guarantee a clean, stateless call.
class UseAccessTokenSpec < BaseSpec
  it 'retrieves general settings with valid token' do
    client = Zitadel::Client::Zitadel.with_access_token(@base_url, @auth_token)
    client.settings.get_general_settings
  end

  it 'raises an ApiError with invalid token' do
    client = Zitadel::Client::Zitadel.with_access_token(
      @base_url,
      'invalid'
    )
    assert_raises(Zitadel::Client::ZitadelError) do
      client.settings.get_general_settings
    end
  end
end
