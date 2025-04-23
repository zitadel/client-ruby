# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../spec_helper'

# SettingsService Integration Tests (Client Credentials)
#
# This suite verifies the Zitadel SettingsService API's general settings
# endpoint works when authenticating via Client Credentials:
#
#  1. Retrieve general settings successfully with valid credentials
#  2. Expect an ApiError when using invalid credentials
#
# Each test runs in isolation: the client is instantiated in each example to
# guarantee a clean, stateless call.
describe 'Zitadel SettingsService (Client Credentials)' do
  it 'retrieves general settings with valid credentials' do
    client = ZitadelClient::Zitadel.with_client_credentials(
      ENV.fetch('BASE_URL')      { raise 'BASE_URL not set' },
      ENV.fetch('CLIENT_ID')     { raise 'CLIENT_ID not set' },
      ENV.fetch('CLIENT_SECRET') { raise 'CLIENT_SECRET not set' }
    )
    client.settings.settings_service_get_general_settings
  end

  it 'raises an ApiError with invalid credentials' do
    client = ZitadelClient::Zitadel.with_client_credentials(
      ENV.fetch('BASE_URL') { raise 'BASE_URL not set' },
      'invalid',
      'invalid'
    )
    assert_raises(ZitadelClient::ApiError) do
      client.settings.settings_service_get_general_settings
    end
  end
end
