# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../spec_helper'
require 'openssl'
require 'tempfile'
require_relative '../base_spec'

# SettingsService Integration Tests (Private Key Assertion)
#
# This suite verifies the Zitadel SettingsService API's general settings
# endpoint works when authenticating via a private key assertion:
#
#  1. Retrieve general settings successfully with a valid private key
#  2. Expect an OAuth2ServerError when signing with a key the instance does not know
#
# Each test runs in isolation: the client is instantiated in each example to
# guarantee a clean, stateless call.
class UsePrivateKeySpec < BaseSpec
  it 'retrieves general settings with valid private key' do
    authenticator = Zitadel::Client::Auth::WebTokenAuthenticator.from_json(@base_url, @jwt_key)
    client = Zitadel::Client::Zitadel.with_authenticator(authenticator)
    client.settings_service.get_general_settings({})
  end

  it 'raises an OAuth2ServerError with a key the instance does not know' do
    authenticator = Zitadel::Client::Auth::WebTokenAuthenticator
                    .builder(@base_url, 'invalid', OpenSSL::PKey::RSA.new(2048).to_pem)
                    .key_id('invalid')
                    .build
    client = Zitadel::Client::Zitadel.with_authenticator(authenticator)
    error = assert_raises(Zitadel::Client::Errors::OAuth2ServerError) do
      client.settings_service.get_general_settings({})
    end
    assert_instance_of Zitadel::Client::Errors::OAuth2ServerError, error
  end
end
