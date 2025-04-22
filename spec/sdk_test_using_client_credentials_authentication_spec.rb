# frozen_string_literal: true

require 'minitest/autorun'
require 'securerandom'
require_relative 'spec_helper'

describe 'Zitadel Client' do
  before do
    @client_id     = ENV.fetch('CLIENT_ID', nil)
    @client_secret = ENV.fetch('CLIENT_SECRET', nil)
    @base_url      = ENV.fetch('BASE_URL', nil)
    @user_id       = create_user(@base_url, @client_id, @client_secret)
  end

  # rubocop:disable Metrics/MethodLength
  def create_user(base_url, client_id, client_secret)
    client = ZitadelClient::Zitadel.with_client_credentials(base_url, client_id, client_secret)

    begin
      response = client.users.user_service_add_human_user(
        ZitadelClient::UserServiceAddHumanUserRequest.new(
          username: SecureRandom.hex,
          profile: ZitadelClient::UserServiceSetHumanProfile.new(given_name: 'John', family_name: 'Doe'),
          email: ZitadelClient::UserServiceSetHumanEmail.new(email: "johndoe#{SecureRandom.hex}@caos.ag")
        )
      )
      puts "User created: #{response}"
      response.user_id
    rescue StandardError => e
      raise "Exception while creating user: #{e.message}"
    end
  end
  # rubocop:enable Metrics/MethodLength

  describe 'with valid token' do
    it 'deactivates and reactivates a user' do
      client = ZitadelClient::Zitadel.with_client_credentials(@base_url, @client_id, @client_secret)

      begin
        deactivate_response = client.users.user_service_deactivate_user(@user_id)
        puts "User deactivated: #{deactivate_response}"

        reactivate_response = client.users.user_service_reactivate_user(@user_id)
        puts "User reactivated: #{reactivate_response}"

        # you can add real assertions here, for example:
        # _(reactivate_response).must_respond_to :user_id
      rescue StandardError => e
        flunk "Exception when calling deactivate_user or reactivate_user with valid token: #{e.message}"
      end
    end
  end

  describe 'with invalid token' do
    it 'does not deactivate or reactivate a user' do
      client = ZitadelClient::Zitadel.with_client_credentials(@base_url, 'id', 'secret')

      # deactivate should raise
      assert_raises(StandardError) do
        client.users.user_service_deactivate_user(@user_id)
      end

      # reactivate should raise
      assert_raises(StandardError) do
        client.users.user_service_reactivate_user(@user_id)
      end
    end
  end
end
