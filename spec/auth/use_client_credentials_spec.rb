# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../spec_helper'
require_relative '../base_spec'
require 'net/http'
require 'uri'
require 'json'

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
class UseClientCredentialsSpec < BaseSpec
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
  def generate_user_secret(token, login_name = 'api-user')
    user_id_uri = URI("http://localhost:8099/management/v1/global/users/_by_login_name?loginName=#{URI.encode_www_form_component(login_name)}")

    # noinspection RubyMismatchedArgumentType
    user_id_http = Net::HTTP.new(user_id_uri.host, user_id_uri.port)
    user_id_request = Net::HTTP::Get.new(user_id_uri)
    user_id_request['Authorization'] = "Bearer #{token}"
    user_id_request['Accept'] = 'application/json'

    user_id_response = user_id_http.request(user_id_request)

    unless user_id_response.is_a?(Net::HTTPSuccess)
      raise "API call to retrieve user failed for login name: '#{login_name}'. Response: #{user_id_response.body}"
    end

    user_response_map = JSON.parse(user_id_response.body)
    user_id = user_response_map.dig('user', 'id')

    if user_id && !user_id.empty?
      secret_uri = URI("http://localhost:8099/management/v1/users/#{user_id}/secret")

      # noinspection RubyMismatchedArgumentType
      secret_http = Net::HTTP.new(secret_uri.host, secret_uri.port)
      secret_request = Net::HTTP::Put.new(secret_uri)
      secret_request['Authorization'] = "Bearer #{token}"
      secret_request['Content-Type'] = 'application/json'
      secret_request['Accept'] = 'application/json'
      secret_request.body = '{}'

      secret_response = secret_http.request(secret_request)

      unless secret_response.is_a?(Net::HTTPSuccess)
        raise "API call to generate secret failed for user ID: '#{user_id}'. Response: #{secret_response.body}"
      end

      secret_data = JSON.parse(secret_response.body)
      client_id = secret_data['clientId']
      client_secret = secret_data['clientSecret']

      if client_id && !client_id.empty? && client_secret && !client_secret.empty?
        return { clientId: client_id, clientSecret: client_secret }
      end

      puts secret_response.body
      raise "API response for secret is missing 'clientId' or 'clientSecret'."

    else
      puts user_id_response.body
      raise "Could not parse a valid user ID from API response for login name: '#{login_name}'."
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

  it 'retrieves general settings with valid credentials' do
    credentials = generate_user_secret(@auth_token, 'api-user')
    client = Zitadel::Client::Zitadel.with_client_credentials(
      @base_url,
      credentials[:clientId],
      credentials[:clientSecret]
    )
    client.settings.settings_service_get_general_settings
  end

  it 'raises an ApiError with invalid credentials' do
    client = Zitadel::Client::Zitadel.with_client_credentials(
      @base_url,
      'invalid',
      'invalid'
    )
    assert_raises(Zitadel::Client::ZitadelError) do
      client.settings.settings_service_get_general_settings
    end
  end
end
