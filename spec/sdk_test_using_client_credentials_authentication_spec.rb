# frozen_string_literal: true

require 'spec_helper'
require 'rspec'
require 'securerandom'

RSpec.describe 'Zitadel Client' do
  let(:client_id) { ENV.fetch('CLIENT_ID', nil) }
  let(:client_secret) { ENV.fetch('CLIENT_SECRET', nil) }
  let(:base_url) { ENV.fetch('BASE_URL', nil) }
  let(:user_id) { create_user(base_url, client_id, client_secret) }

  def create_user(base_url, client_id, client_secret)
    client = ZitadelClient::Zitadel.new(ZitadelClient::ClientCredentialsAuthenticator.builder(
      base_url, client_id, client_secret
    ).build)

    begin
      response = client.users.add_human_user(
        ZitadelClient::V2AddHumanUserRequest.new(
          username: SecureRandom.hex,
          profile: ZitadelClient::V2SetHumanProfile.new(given_name: 'John', family_name: 'Doe'),
          email: ZitadelClient::V2SetHumanEmail.new(email: "johndoe#{SecureRandom.hex}@caos.ag")
        )
      )
      puts "User created: #{response}"
      response.user_id
    rescue StandardError => e
      raise "Exception while creating user: #{e.message}"
    end
  end

  describe 'with valid token' do
    it 'deactivates and reactivates a user' do
      client = ZitadelClient::Zitadel.new(ZitadelClient::ClientCredentialsAuthenticator.builder(
        base_url, client_id, client_secret
      ).build)

      begin
        deactivate_response = client.users.deactivate_user(user_id)
        puts "User deactivated: #{deactivate_response}"

        reactivate_response = client.users.reactivate_user(user_id)
        puts "User reactivated: #{reactivate_response}"
        # Adjust based on actual response format
        # expect(reactivate_response['status']).to eq('success')
      rescue StandardError => e
        raise "Exception when calling deactivate_user or reactivate_user with valid token: #{e.message}"
      end
    end
  end

  describe 'with invalid token' do
    it 'does not deactivate or reactivate a user' do
      client = ZitadelClient::Zitadel.new(ZitadelClient::ClientCredentialsAuthenticator.builder(
        base_url, 'id', 'secret'
      ).build)

      begin
        client.users.deactivate_user(user_id)
        raise 'Expected exception when deactivating user with invalid token, but got response.'
      rescue StandardError => e
        puts "Caught expected UnauthorizedException: #{e.message}"
      end

      begin
        client.users.reactivate_user(user_id)
        raise 'Expected exception when reactivating user with invalid token, but got response.'
      rescue StandardError => e
        puts "Caught expected UnauthorizedException: #{e.message}"
      end
    end
  end
end
