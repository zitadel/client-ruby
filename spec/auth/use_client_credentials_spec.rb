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
  let(:base_url)      { ENV.fetch('BASE_URL')      { raise 'BASE_URL not set'      } }
  let(:client_id)     { ENV.fetch('CLIENT_ID')     { raise 'CLIENT_ID not set'     } }
  let(:client_secret) { ENV.fetch('CLIENT_SECRET') { raise 'CLIENT_SECRET not set' } }
  let(:zitadel_client)  do
    ZitadelClient::Zitadel.with_client_credentials(
      base_url,
      client_id,
      client_secret
    )
  end

  it 'retrieves general settings with valid credentials' do
    client = zitadel_client
    client.settings.settings_service_get_general_settings
  end

  it 'raises an ApiError with invalid credentials' do
    client = ZitadelClient::Zitadel.with_client_credentials(
      base_url,
      'invalid',
      'invalid'
    )
    assert_raises(ZitadelClient::ApiError) do
      client.settings.settings_service_get_general_settings
    end
  end
end
