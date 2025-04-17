# frozen_string_literal: true

# rubocop:disable RSpec/ExampleLength
# rubocop:disable Metrics/MethodLength

require 'spec_helper'
require 'rspec'
require 'securerandom'

RSpec.describe 'Zitadel Client' do
  let(:valid_token) { ENV.fetch('AUTH_TOKEN', nil) }
  let(:invalid_token) { 'whoops' }
  let(:base_url) { ENV.fetch('BASE_URL', nil) }
  let(:user_id) { create_user(valid_token, base_url) }

  def create_user(valid_token, base_url)
    client = ZitadelClient::Zitadel.new(ZitadelClient::PersonalAccessTokenAuthenticator.new(
                                          base_url, valid_token
                                        ))

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
      client = ZitadelClient::Zitadel.new(ZitadelClient::PersonalAccessTokenAuthenticator.new(
                                            base_url, valid_token
                                          ))

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
      client = ZitadelClient::Zitadel.new(ZitadelClient::PersonalAccessTokenAuthenticator.new(
                                            base_url, invalid_token
                                          ))

      begin
        client.users.deactivate_user(user_id)
        raise 'Expected exception when deactivating user with invalid token, but got response.'
      rescue ZitadelClient::ApiError => e
        puts "Caught expected UnauthorizedException: #{e.message}"
      rescue StandardError => e
        raise "Invalid exception when calling the function: #{e.message}"
      end

      begin
        client.users.reactivate_user(user_id)
        raise 'Expected exception when reactivating user with invalid token, but got response.'
      rescue ZitadelClient::ApiError => e
        puts "Caught expected UnauthorizedException: #{e.message}"
      rescue StandardError => e
        raise "Invalid exception when calling the function: #{e.message}"
      end
    end
  end
end

# rubocop:enable RSpec/ExampleLength
# rubocop:enable Metrics/MethodLength
