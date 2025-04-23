# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../spec_helper'

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
describe 'Zitadel SettingsService (Personal Access Token)' do
  it 'retrieves general settings with valid token' do
    client = ZitadelClient::Zitadel.with_access_token(
      ENV.fetch('BASE_URL')   { raise 'BASE_URL not set' },
      ENV.fetch('AUTH_TOKEN') { raise 'AUTH_TOKEN not set' }
    )
    client.settings.settings_service_get_general_settings
  end

  it 'raises an ApiError with invalid token' do
    client = ZitadelClient::Zitadel.with_access_token(
      ENV.fetch('BASE_URL') { raise 'BASE_URL not set' },
      'invalid'
    )
    assert_raises(ZitadelClient::ApiError) do
      client.settings.settings_service_get_general_settings
    end
  end
end
