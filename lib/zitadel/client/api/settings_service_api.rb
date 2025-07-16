module Zitadel::Client::Api
  # noinspection RbsMissingTypeSignature
  class SettingsServiceApi
    def initialize(api_client)
      @api_client = api_client
    end

    def get_general_settings(body = {})
      if body.nil?
        fail ArgumentError, "Missing the required parameter 'body' when calling get_general_settings"
      end

      api_client.invoke_api(
        operation_id: 'get_general_settings',
        path_template: '/zitadel.settings.v2.SettingsService/GetGeneralSettings',
        method: :POST,
        path_params: {},
        query_params: {},
        header_params: {},
        body: body,
        success_type: Zitadel::Client::Models::SettingsServiceGetGeneralSettingsResponse,
        error_types: {}
      )
    end

    def get_login_settings(settings_service_get_login_settings_request)
      if settings_service_get_login_settings_request.nil?
        fail ArgumentError, "Missing the required parameter 'settings_service_get_login_settings_request' when calling get_login_settings"
      end

      api_client.invoke_api(
        operation_id: 'get_login_settings',
        path_template: '/zitadel.settings.v2.SettingsService/GetLoginSettings',
        method: :POST,
        path_params: {},
        query_params: {},
        header_params: {},
        body: settings_service_get_login_settings_request,
        success_type: Zitadel::Client::Models::SettingsServiceGetLoginSettingsResponse,
        error_types: {}
      )
    end

    private

    attr_reader :api_client
  end
end
