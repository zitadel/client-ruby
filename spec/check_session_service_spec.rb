# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'base_spec'

# SessionService Integration Tests
#
# This suite verifies the Zitadel SessionService API's basic operations using a
# personal access token:
#
#  1. Create a session with specified checks and lifetime
#  2. Retrieve the session by ID
#  3. List sessions and ensure the created session appears
#  4. Update the session's lifetime and confirm a new token is returned
#
# Each test runs in isolation: a new session is created in `before` and deleted
# in `after` to ensure a clean state.

require_relative 'spec_helper'
require 'securerandom'

class SessionServiceSanityCheckSpec < BaseSpec
  def client
    Zitadel::Client::Zitadel.with_access_token(@base_url, @auth_token)
  end

  before do
    username = SecureRandom.hex
    request = Zitadel::Client::Models::UserServiceAddHumanUserRequest.new(
      username: username,
      profile: Zitadel::Client::Models::UserServiceSetHumanProfile.new(
        given_name: 'John',
        family_name: 'Doe'
      ),
      email: Zitadel::Client::Models::UserServiceSetHumanEmail.new(
        email: "johndoe#{SecureRandom.hex}@example.com"
      )
    )

    @user = client.users.user_service_add_human_user(request)
    request = Zitadel::Client::Models::SessionServiceCreateSessionRequest.new(
      checks: Zitadel::Client::Models::SessionServiceChecks.new(
        user: Zitadel::Client::Models::SessionServiceCheckUser.new(
          login_name: username
        )
      ),
      lifetime: '18000s'
    )
    resp = client.sessions.session_service_create_session(request)
    @session_id = resp.session_id
    @session_token = resp.session_token
  end

  after do
    delete_req = Zitadel::Client::Models::SessionServiceDeleteSessionRequest.new
    begin
      client.sessions.session_service_delete_session(@session_id, delete_req)
    rescue StandardError
      # Ignore cleanup errors
    end
  end

  it 'retrieves the session details by the session identifier' do
    response = client.sessions.session_service_get_session(
      @session_id,
      session_token: @session_token
    )
    _(response.session.id).must_equal @session_id
  end

  it 'raises an error when retrieving a non-existent session' do
    assert_raises(Zitadel::Client::ApiError) do
      client.sessions.session_service_get_session(
        SecureRandom.uuid,
        session_token: @session_token
      )
    end
  end

  it 'includes the created session when listing all sessions' do
    request = Zitadel::Client::Models::SessionServiceListSessionsRequest.new(queries: [])
    response = client.sessions.session_service_list_sessions(request)
    _(response.sessions.map(&:id)).must_include @session_id
  end

  it 'updates the session lifetime and returns a new token' do
    request = Zitadel::Client::Models::SessionServiceSetSessionRequest.new(lifetime: '36000s')
    response = client.sessions.session_service_set_session(
      @session_id,
      request
    )
    _(response.session_token).must_be_instance_of String
  end
end
