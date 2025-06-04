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

describe 'Zitadel SessionService' do
  let(:base_url) { ENV.fetch('BASE_URL') { raise 'BASE_URL not set' } }
  let(:valid_token) { ENV.fetch('AUTH_TOKEN') { raise 'AUTH_TOKEN not set' } }
  let(:client) do
    Zitadel::Client::Zitadel.with_access_token(
      base_url,
      valid_token
    )
  end

  before do
    req = Zitadel::Client::Models::SessionServiceCreateSessionRequest.new(
      checks: Zitadel::Client::Models::SessionServiceChecks.new(
        user: Zitadel::Client::Models::SessionServiceCheckUser.new(login_name: 'johndoe')
      ),
      lifetime: '18000s'
    )
    resp = client.sessions.create_session(req)
    @session_id = resp.session_id
    @session_token = resp.session_token
  end

  after do
    request = Zitadel::Client::Models::SessionServiceDeleteSessionRequest.new(session_id: @session_id)
    client.sessions.delete_session(request)
  rescue StandardError
    # Ignore cleanup errors
  end

  it 'retrieves the session details by the session identifier' do
    request = Zitadel::Client::Models::SessionServiceGetSessionRequest.new(session_id: @session_id, session_token: @session_token)
    response = client.sessions.get_session(request)
    _(response.session.id).must_equal @session_id
  end

  it 'raises an error when retrieving a non-existent session' do
    request = Zitadel::Client::Models::SessionServiceGetSessionRequest.new(session_id: SecureRandom.uuid,
                                                                           session_token: @session_token)
    assert_raises(Zitadel::Client::ApiError) do
      client.sessions.get_session(request)
    end
  end

  it 'includes the created session when listing all sessions' do
    request = Zitadel::Client::Models::SessionServiceListSessionsRequest.new(queries: [])
    response = client.sessions.list_sessions(request)
    _(response.sessions.map(&:id)).must_include @session_id
  end

  it 'updates the session lifetime and returns a new token' do
    request = Zitadel::Client::Models::SessionServiceSetSessionRequest.new(session_id: @session_id, lifetime: '36000s')
    response = client.sessions.set_session(request)
    _(response.session_token).must_be_instance_of String
  end
end
