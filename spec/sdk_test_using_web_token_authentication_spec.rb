# frozen_string_literal: true

require_relative 'spec_helper'
require 'securerandom'
require 'tempfile'

describe 'Zitadel Client (JWT Bearer OAuth)' do
  before do
    jwt_key = ENV.fetch('JWT_KEY') { raise 'JWT_KEY not set in environment' }
    # Create and retain the Tempfile so it isn't GC'd before the test runs
    @jwt_file = Tempfile.new(%w[jwt .json])
    @jwt_file.write(jwt_key)
    @jwt_file.flush
    @jwt_file.close
    @key_file = @jwt_file.path

    @base_url = ENV.fetch('BASE_URL', nil)
    @user_id  = create_user(@key_file, @base_url)
  end

  def create_temp_keyfile(jwt_key)
    file = Tempfile.new('jwt_')
    file.write(jwt_key)
    file.close
    file.path
  end

  # rubocop:disable Metrics/MethodLength
  def create_user(key_file, base_url)
    client = ZitadelClient::Zitadel.with_private_key(base_url, key_file)

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
      raise ArgumentError, 'key_file cannot be nil' if @key_file.nil?

      client = ZitadelClient::Zitadel.with_private_key(@base_url, @key_file)

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
end
