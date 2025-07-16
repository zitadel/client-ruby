module Zitadel::Client::Api
  # noinspection RbsMissingTypeSignature
  class SessionServiceApi
    def initialize(api_client)
      @api_client = api_client
    end

    def create_session(session_service_create_session_request)
      if session_service_create_session_request.nil?
        fail ArgumentError, "Missing the required parameter 'session_service_create_session_request' when calling create_session"
      end

      api_client.invoke_api(
        operation_id: 'create_session',
        path_template: '/zitadel.session.v2.SessionService/CreateSession',
        method: :POST,
        path_params: {},
        query_params: {},
        header_params: {},
        body: session_service_create_session_request,
        success_type: Zitadel::Client::Models::SessionServiceCreateSessionResponse,
        error_types: {}
      )
    end

    def delete_session(session_service_delete_session_request)
      if session_service_delete_session_request.nil?
        fail ArgumentError, "Missing the required parameter 'session_service_delete_session_request' when calling delete_session"
      end

      api_client.invoke_api(
        operation_id: 'delete_session',
        path_template: '/zitadel.session.v2.SessionService/DeleteSession',
        method: :POST,
        path_params: {},
        query_params: {},
        header_params: {},
        body: session_service_delete_session_request,
        success_type: Zitadel::Client::Models::SessionServiceDeleteSessionResponse,
        error_types: {}
      )
    end

    def get_session(session_service_get_session_request)
      if session_service_get_session_request.nil?
        fail ArgumentError, "Missing the required parameter 'session_service_get_session_request' when calling get_session"
      end

      api_client.invoke_api(
        operation_id: 'get_session',
        path_template: '/zitadel.session.v2.SessionService/GetSession',
        method: :POST,
        path_params: {},
        query_params: {},
        header_params: {},
        body: session_service_get_session_request,
        success_type: Zitadel::Client::Models::SessionServiceGetSessionResponse,
        error_types: {}
      )
    end

    def list_sessions(session_service_list_sessions_request)
      if session_service_list_sessions_request.nil?
        fail ArgumentError, "Missing the required parameter 'session_service_list_sessions_request' when calling list_sessions"
      end

      api_client.invoke_api(
        operation_id: 'list_sessions',
        path_template: '/zitadel.session.v2.SessionService/ListSessions',
        method: :POST,
        path_params: {},
        query_params: {},
        header_params: {},
        body: session_service_list_sessions_request,
        success_type: Zitadel::Client::Models::SessionServiceListSessionsResponse,
        error_types: {}
      )
    end

    def set_session(session_service_set_session_request)
      if session_service_set_session_request.nil?
        fail ArgumentError, "Missing the required parameter 'session_service_set_session_request' when calling set_session"
      end

      api_client.invoke_api(
        operation_id: 'set_session',
        path_template: '/zitadel.session.v2.SessionService/SetSession',
        method: :POST,
        path_params: {},
        query_params: {},
        header_params: {},
        body: session_service_set_session_request,
        success_type: Zitadel::Client::Models::SessionServiceSetSessionResponse,
        error_types: {}
      )
    end

    private

    attr_reader :api_client
  end
end
