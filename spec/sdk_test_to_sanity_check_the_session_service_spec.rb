# frozen_string_literal: true

require 'minitest/autorun'

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

VALID_TOKEN = ENV.fetch('AUTH_TOKEN')
BASE_URL    = ENV.fetch('BASE_URL')
CLIENT      = ZitadelClient::Zitadel.with_access_token(BASE_URL, VALID_TOKEN)

describe 'Zitadel SessionService' do
  # Setup: create a fresh session before each test example
  before do
    req  = ZitadelClient::SessionServiceCreateSessionRequest.new(
      checks: ZitadelClient::SessionServiceChecks.new(
        user: ZitadelClient::SessionServiceCheckUser.new(login_name: 'johndoe')
      ),
      lifetime: '18000s'
    )
    resp = CLIENT.sessions.session_service_create_session(req)
    @session_id    = resp.session_id
    @session_token = resp.session_token
  end

  # Teardown: delete the session after each test example
  after do
    delete_req = ZitadelClient::SessionServiceDeleteSessionBody.new
    begin
      CLIENT.sessions.session_service_delete_session(@session_id, delete_req)
    rescue StandardError
      # Ignore cleanup errors
    end
  end

  it 'retrieves the session details by the session identifier' do
    response = CLIENT.sessions.session_service_get_session(
      @session_id,
      session_token: @session_token
    )
    _(response.session.id).must_equal @session_id
  end

  it 'raises an error when retrieving a non-existent session' do
    assert_raises(ZitadelClient::ApiError) do
      CLIENT.sessions.session_service_get_session(
        SecureRandom.uuid,
        session_token: @session_token
      )
    end
  end

  it 'includes the created session when listing all sessions' do
    request  = ZitadelClient::SessionServiceListSessionsRequest.new(queries: [])
    response = CLIENT.sessions.session_service_list_sessions(
      request
    )
    _(response.sessions.map(&:id)).must_include @session_id
  end

  it 'updates the session lifetime and returns a new token' do
    request  = ZitadelClient::SessionServiceSetSessionRequest.new(lifetime: '36000s')
    response = CLIENT.sessions.session_service_set_session(
      @session_id,
      request
    )
    _(response.session_token).must_be_instance_of String
  end
end
