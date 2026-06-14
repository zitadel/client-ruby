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
  MANAGEMENT_BASE = 'http://localhost:18102/management/v1'

  def generate_user_secret(token, login_name = 'api-user')
    user_id = lookup_user_id(token, login_name)
    create_secret(token, user_id)
  end

  # Resolves the user id for a login name via the management API.
  def lookup_user_id(token, login_name)
    query = URI.encode_www_form_component(login_name)
    uri = URI("#{MANAGEMENT_BASE}/global/users/_by_login_name?loginName=#{query}")
    response = get_json(uri, token)
    unless response.is_a?(Net::HTTPSuccess)
      raise "API call to retrieve user failed for login name: '#{login_name}'. Response: #{response.body}"
    end

    user_id = JSON.parse(response.body).dig('user', 'id')
    return user_id if user_id && !user_id.empty?

    puts response.body
    raise "Could not parse a valid user ID from API response for login name: '#{login_name}'."
  end

  # Generates and returns a client-credentials secret for the given user id.
  def create_secret(token, user_id)
    response = put_json(URI("#{MANAGEMENT_BASE}/users/#{user_id}/secret"), token)
    unless response.is_a?(Net::HTTPSuccess)
      raise "API call to generate secret failed for user ID: '#{user_id}'. Response: #{response.body}"
    end

    data = JSON.parse(response.body)
    client_id = data['clientId']
    client_secret = data['clientSecret']
    return { clientId: client_id, clientSecret: client_secret } if present?(client_id) && present?(client_secret)

    puts response.body
    raise "API response for secret is missing 'clientId' or 'clientSecret'."
  end

  def present?(value)
    value && !value.empty?
  end

  # noinspection RubyMismatchedArgumentType
  def get_json(uri, token)
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{token}"
    request['Accept'] = 'application/json'
    Net::HTTP.new(uri.host, uri.port).request(request)
  end

  # noinspection RubyMismatchedArgumentType
  def put_json(uri, token)
    request = Net::HTTP::Put.new(uri)
    request['Authorization'] = "Bearer #{token}"
    request['Content-Type'] = 'application/json'
    request['Accept'] = 'application/json'
    request.body = '{}'
    Net::HTTP.new(uri.host, uri.port).request(request)
  end
  it 'retrieves general settings with valid credentials' do
    credentials = generate_user_secret(@auth_token, 'api-user')
    client = Zitadel::Client::Zitadel.with_client_credentials(
      @base_url,
      credentials.fetch(:clientId),
      credentials.fetch(:clientSecret)
    )
    client.settings.get_general_settings({})
  end

  it 'raises an ApiError with invalid credentials' do
    client = Zitadel::Client::Zitadel.with_client_credentials(
      @base_url,
      'invalid',
      'invalid'
    )
    assert_raises(Zitadel::Client::ZitadelError) do
      client.settings.get_general_settings({})
    end
  end
end
