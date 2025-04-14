require 'spec_helper'
require 'rspec'
require 'securerandom'

RSpec.describe 'Zitadel Client' do
  let(:key_file) do
    jwt_key = ENV['JWT_KEY'] or fail("JWT_KEY not set in environment")
    file = Tempfile.new('jwt_')
    file.write(jwt_key)
    file.close
    file.path
  end
  let(:base_url) { ENV['BASE_URL'] }
  let(:user_id) { create_user(key_file, base_url) }

  def create_user(key_file, base_url)
    client = ZitadelClient::Zitadel.new(ZitadelClient::WebTokenAuthenticator::from_json(base_url, key_file))

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
      fail "Exception while creating user: #{e.message}"
    end
  end

  describe 'with valid token' do
    it 'deactivates and reactivates a user' do
      client = ZitadelClient::Zitadel.new(ZitadelClient::WebTokenAuthenticator::from_json(base_url, key_file))

      begin
        deactivate_response = client.users.deactivate_user(user_id)
        puts "User deactivated: #{deactivate_response}"

        reactivate_response = client.users.reactivate_user(user_id)
        puts "User reactivated: #{reactivate_response}"
        # Adjust based on actual response format
        # expect(reactivate_response['status']).to eq('success')
      rescue StandardError => e
        fail "Exception when calling deactivate_user or reactivate_user with valid token: #{e.message}"
      end
    end
  end
end
