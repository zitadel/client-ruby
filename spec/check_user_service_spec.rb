# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'spec_helper'
require 'securerandom'

# UserService Integration Tests
#
# This suite verifies the Zitadel UserService API's basic operations using a
# personal access token:
#
#  1. Create a human user
#  2. Retrieve the user by ID
#  3. List users and ensure the created user appears
#  4. Update the user's email and confirm the change
#  5. Error when retrieving a non-existent user
#
# Each test runs in isolation: a new user is created in `before` and deleted in
# `after` to ensure a clean state.

describe 'Zitadel UserService' do
  let(:base_url) { ENV.fetch('BASE_URL') { raise 'BASE_URL not set' } }
  let(:valid_token) { ENV.fetch('AUTH_TOKEN') { raise 'AUTH_TOKEN not set' } }
  let(:client) do
    Zitadel::Client::Zitadel.with_access_token(
      base_url,
      valid_token
    )
  end

  before do
    request = Zitadel::Client::Models::UserServiceAddHumanUserRequest.new(
      username: SecureRandom.hex,
      profile: Zitadel::Client::Models::UserServiceSetHumanProfile.new(
        given_name: 'John',
        family_name: 'Doe'
      ),
      email: Zitadel::Client::Models::UserServiceSetHumanEmail.new(
        email: "johndoe#{SecureRandom.hex}@example.com"
      )
    )

    @user = client.users.add_human_user(request)
  end

  after do
    client.users.delete_user(UserServiceDeleteUserRequest.new(user_id: @user.user_id))
  rescue StandardError
    # Ignore cleanup errors
  end

  it 'retrieves the user details by ID' do
    response = client.users.get_user_by_id(UserServiceGetUserByIDRequest.new(user_id: @user.user_id))
    _(response.user.user_id).must_equal @user.user_id
  end

  it 'raises an error when retrieving a non-existent user' do
    assert_raises(Zitadel::Client::ApiError) do
      client.users.get_user_by_id(UserServiceGetUserByIDRequest.new(user_id: SecureRandom.uuid))
    end
  end

  it 'includes the created user when listing all users' do
    request = Zitadel::Client::Models::UserServiceListUsersRequest.new(queries: [])
    response = client.users.list_users(request)
    _(response.result.map(&:user_id)).must_include @user.user_id
  end

  it "updates the user's email and reflects the change" do
    new_email = "updated#{SecureRandom.hex}@example.com"
    update_req = Zitadel::Client::Models::UserServiceUpdateHumanUserRequest.new(
      user_id: @user.user_id,
      email: Zitadel::Client::Models::UserServiceSetHumanEmail.new(email: new_email)
    )
    client.users.update_human_user(update_req)

    response = client.users.get_user_by_id(UserServiceGetUserByIDRequest.new(user_id: @user.user_id))
    _(response.user.human.email.email).must_equal new_email
  end
end
