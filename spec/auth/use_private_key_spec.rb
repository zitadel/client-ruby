# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../spec_helper'
require 'tempfile'

# SettingsService Integration Tests (Private Key Assertion)
#
# This suite verifies the Zitadel SettingsService API's general settings
# endpoint works when authenticating via a private key assertion:
#
#  1. Retrieve general settings successfully with a valid private key
#  2. Expect an ApiError when using an invalid private key
#
# Each test runs in isolation: the client is instantiated in each example to
# guarantee a clean, stateless call.
describe 'Zitadel SettingsService (Private Key Assertion)' do
  let(:base_url) { ENV.fetch('BASE_URL') { raise 'BASE_URL not set' } }
  let(:jwt_file) do
    file = Tempfile.new(%w[jwt .json])
    file.write(ENV.fetch('JWT_KEY') { raise 'JWT_KEY not set' })
    file.flush
    file.close
    file
  end
  let(:zitadel_client) do
    ZitadelClient::Zitadel.with_private_key(
      base_url,
      jwt_file.path
    )
  end

  it 'retrieves general settings with valid private key' do
    client = zitadel_client
    client.settings.settings_service_get_general_settings
  end

  it 'raises an ApiError with invalid private key' do
    client = ZitadelClient::Zitadel.with_private_key(
      'https://zitadel.cloud',
      jwt_file.path
    )
    assert_raises(ZitadelClient::ZitadelError) do
      client.settings.settings_service_get_general_settings
    end
  end
end
