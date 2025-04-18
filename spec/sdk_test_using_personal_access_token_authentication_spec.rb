# frozen_string_literal: true

require_relative 'spec_helper'
require 'securerandom'

describe 'Zitadel Client (Personal Access Token)' do
  before do
    @valid_token   = ENV.fetch('AUTH_TOKEN', nil)
    @invalid_token = 'whoops'
    @base_url      = ENV.fetch('BASE_URL', nil)
    @user_id       = create_user(@valid_token, @base_url)
  end

  # rubocop:disable Metrics/MethodLength
  def create_user(token, base_url)
    client = ZitadelClient::Zitadel.new(
      ZitadelClient::PersonalAccessTokenAuthenticator.new(base_url, token)
    )

    begin
      resp = client.users.add_human_user(
        ZitadelClient::V2AddHumanUserRequest.new(
          username: SecureRandom.hex,
          profile: ZitadelClient::V2SetHumanProfile.new(given_name: 'John', family_name: 'Doe'),
          email: ZitadelClient::V2SetHumanEmail.new(email: "johndoe#{SecureRandom.hex}@caos.ag")
        )
      )
      puts "User created: #{resp}"
      resp.user_id
    rescue StandardError => e
      raise "Exception while creating user: #{e.message}"
    end
  end
  # rubocop:enable Metrics/MethodLength

  describe 'with valid token' do
    it 'deactivates and reactivates a user without error' do
      client = ZitadelClient::Zitadel.new(
        ZitadelClient::PersonalAccessTokenAuthenticator.new(@base_url, @valid_token)
      )

      begin
        deactivate_resp = client.users.deactivate_user(@user_id)
        puts "User deactivated: #{deactivate_resp}"

        reactivate_resp = client.users.reactivate_user(@user_id)
        puts "User reactivated: #{reactivate_resp}"
      rescue StandardError => e
        flunk "Exception when calling deactivate_user or reactivate_user with valid token: #{e.message}"
      end
    end
  end

  describe 'with invalid token' do
    it 'raises an ApiError when deactivating or reactivating' do
      client = ZitadelClient::Zitadel.new(
        ZitadelClient::PersonalAccessTokenAuthenticator.new(@base_url, @invalid_token)
      )

      # Expect API authentication errors
      assert_raises(ZitadelClient::ApiError) do
        client.users.deactivate_user(@user_id)
      end

      assert_raises(ZitadelClient::ApiError) do
        client.users.reactivate_user(@user_id)
      end
    end
  end
end
