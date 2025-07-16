module Zitadel::Client::Api
  # noinspection RbsMissingTypeSignature
  class UserServiceApi
    def initialize(api_client)
      @api_client = api_client
    end

    def add_human_user(user_service_add_human_user_request)
      if user_service_add_human_user_request.nil?
        fail ArgumentError, "Missing the required parameter 'user_service_add_human_user_request' when calling add_human_user"
      end

      api_client.invoke_api(
        operation_id: 'add_human_user',
        path_template: '/zitadel.user.v2.UserService/AddHumanUser',
        method: :POST,
        path_params: {},
        query_params: {},
        header_params: {},
        body: user_service_add_human_user_request,
        success_type: Zitadel::Client::Models::UserServiceAddHumanUserResponse,
        error_types: {}
      )
    end

    def delete_user(user_service_delete_user_request)
      if user_service_delete_user_request.nil?
        fail ArgumentError, "Missing the required parameter 'user_service_delete_user_request' when calling delete_user"
      end

      api_client.invoke_api(
        operation_id: 'delete_user',
        path_template: '/zitadel.user.v2.UserService/DeleteUser',
        method: :POST,
        path_params: {},
        query_params: {},
        header_params: {},
        body: user_service_delete_user_request,
        success_type: Zitadel::Client::Models::UserServiceDeleteUserResponse,
        error_types: {}
      )
    end

    def get_user_by_id(user_service_get_user_by_id_request)
      if user_service_get_user_by_id_request.nil?
        fail ArgumentError, "Missing the required parameter 'user_service_get_user_by_id_request' when calling get_user_by_id"
      end

      api_client.invoke_api(
        operation_id: 'get_user_by_id',
        path_template: '/zitadel.user.v2.UserService/GetUserByID',
        method: :POST,
        path_params: {},
        query_params: {},
        header_params: {},
        body: user_service_get_user_by_id_request,
        success_type: Zitadel::Client::Models::UserServiceGetUserByIDResponse,
        error_types: {}
      )
    end

    def list_users(user_service_list_users_request)
      if user_service_list_users_request.nil?
        fail ArgumentError, "Missing the required parameter 'user_service_list_users_request' when calling list_users"
      end

      api_client.invoke_api(
        operation_id: 'list_users',
        path_template: '/zitadel.user.v2.UserService/ListUsers',
        method: :POST,
        path_params: {},
        query_params: {},
        header_params: {},
        body: user_service_list_users_request,
        success_type: Zitadel::Client::Models::UserServiceListUsersResponse,
        error_types: {}
      )
    end

    def update_human_user(user_service_update_human_user_request)
      if user_service_update_human_user_request.nil?
        fail ArgumentError, "Missing the required parameter 'user_service_update_human_user_request' when calling update_human_user"
      end

      api_client.invoke_api(
        operation_id: 'update_human_user',
        path_template: '/zitadel.user.v2.UserService/UpdateHumanUser',
        method: :POST,
        path_params: {},
        query_params: {},
        header_params: {},
        body: user_service_update_human_user_request,
        success_type: Zitadel::Client::Models::UserServiceUpdateHumanUserResponse,
        error_types: {}
      )
    end

    private

    attr_reader :api_client
  end
end
