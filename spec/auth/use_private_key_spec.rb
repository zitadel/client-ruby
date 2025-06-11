# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../spec_helper'
require 'tempfile'
require_relative '../base_spec'

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
class UsePrivateKeySpec < BaseSpec
  it 'retrieves general settings with valid private key' do
    client = Zitadel::Client::Zitadel.with_private_key(@base_url, @jwt_key)
    client.settings.settings_service_get_general_settings
  end

  it 'raises an ApiError with invalid private key' do
    client = Zitadel::Client::Zitadel.with_private_key(
      'https://zitadel.cloud',
      @jwt_key
    )
    assert_raises(Zitadel::Client::ZitadelError) do
      client.settings.settings_service_get_general_settings
    end
  end
end
