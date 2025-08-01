=begin
#Zitadel SDK

#The Zitadel SDK is a convenience wrapper around the Zitadel APIs to assist you in integrating with your Zitadel environment. This SDK enables you to handle resources, settings, and configurations within the Zitadel platform.

The version of the OpenAPI document: 1.0.0

Generated by: https://openapi-generator.tech
Generator version: 7.13.0

=end

require 'cgi'

module Zitadel::Client::Api
  class SettingsServiceApi
  attr_accessor :api_client

  def initialize(api_client = ApiClient.default)
  @api_client = api_client
  end
      # GetActiveIdentityProviders
      # Get the current active identity providers
          # @param settings_service_get_active_identity_providers_request [SettingsServiceGetActiveIdentityProvidersRequest] 
      # @param [Hash] opts the optional parameters
    # @return [SettingsServiceGetActiveIdentityProvidersResponse]
    def get_active_identity_providers(settings_service_get_active_identity_providers_request, opts = {})
    if @api_client.config.debugging
    @api_client.config.logger.debug 'Calling API: Api::SettingsServiceApi.get_active_identity_providers ...' # MODIFIED
    end
          # verify the required parameter 'settings_service_get_active_identity_providers_request' is set
          if @api_client.config.client_side_validation && settings_service_get_active_identity_providers_request.nil?
          fail ArgumentError, "Missing the required parameter 'settings_service_get_active_identity_providers_request' when calling Api::SettingsServiceApi.get_active_identity_providers" # MODIFIED
          end
    # resource path
    local_var_path = '/zitadel.settings.v2.SettingsService/GetActiveIdentityProviders'

    # query parameters
    query_params = opts[:query_params] || {}

    # header parameters
    header_params = opts[:header_params] || {}
      # HTTP header 'Accept' (if needed)
      header_params['Accept'] = @api_client.select_header_accept(['application/json']) unless header_params['Accept']
      # HTTP header 'Content-Type'
      content_type = @api_client.select_header_content_type(['application/json'])
      if !content_type.nil?
      header_params['Content-Type'] = content_type
      end

    # form parameters
    form_params = opts[:form_params] || {}

    # http body (model)
    post_body = opts[:debug_body] || @api_client.object_to_http_body(settings_service_get_active_identity_providers_request)

    # return_type
    return_type = opts[:debug_return_type] || 'SettingsServiceGetActiveIdentityProvidersResponse'

    # auth_names
    auth_names = opts[:debug_auth_names] || ['zitadelAccessToken']

    new_options = opts.merge(
    :operation => :"Api::SettingsServiceApi.get_active_identity_providers", # MODIFIED
    :header_params => header_params,
    :query_params => query_params,
    :form_params => form_params,
    :body => post_body,
    :auth_names => auth_names,
    :return_type => return_type
    )

    data, status_code, headers = @api_client.call_api(:POST, local_var_path, new_options)
    if @api_client.config.debugging
    @api_client.config.logger.debug "API called: Api::SettingsServiceApi#get_active_identity_providers\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}" # MODIFIED
    end
    return data
    end

      # GetBrandingSettings
      # Get the current active branding settings
          # @param settings_service_get_branding_settings_request [SettingsServiceGetBrandingSettingsRequest] 
      # @param [Hash] opts the optional parameters
    # @return [SettingsServiceGetBrandingSettingsResponse]
    def get_branding_settings(settings_service_get_branding_settings_request, opts = {})
    if @api_client.config.debugging
    @api_client.config.logger.debug 'Calling API: Api::SettingsServiceApi.get_branding_settings ...' # MODIFIED
    end
          # verify the required parameter 'settings_service_get_branding_settings_request' is set
          if @api_client.config.client_side_validation && settings_service_get_branding_settings_request.nil?
          fail ArgumentError, "Missing the required parameter 'settings_service_get_branding_settings_request' when calling Api::SettingsServiceApi.get_branding_settings" # MODIFIED
          end
    # resource path
    local_var_path = '/zitadel.settings.v2.SettingsService/GetBrandingSettings'

    # query parameters
    query_params = opts[:query_params] || {}

    # header parameters
    header_params = opts[:header_params] || {}
      # HTTP header 'Accept' (if needed)
      header_params['Accept'] = @api_client.select_header_accept(['application/json']) unless header_params['Accept']
      # HTTP header 'Content-Type'
      content_type = @api_client.select_header_content_type(['application/json'])
      if !content_type.nil?
      header_params['Content-Type'] = content_type
      end

    # form parameters
    form_params = opts[:form_params] || {}

    # http body (model)
    post_body = opts[:debug_body] || @api_client.object_to_http_body(settings_service_get_branding_settings_request)

    # return_type
    return_type = opts[:debug_return_type] || 'SettingsServiceGetBrandingSettingsResponse'

    # auth_names
    auth_names = opts[:debug_auth_names] || ['zitadelAccessToken']

    new_options = opts.merge(
    :operation => :"Api::SettingsServiceApi.get_branding_settings", # MODIFIED
    :header_params => header_params,
    :query_params => query_params,
    :form_params => form_params,
    :body => post_body,
    :auth_names => auth_names,
    :return_type => return_type
    )

    data, status_code, headers = @api_client.call_api(:POST, local_var_path, new_options)
    if @api_client.config.debugging
    @api_client.config.logger.debug "API called: Api::SettingsServiceApi#get_branding_settings\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}" # MODIFIED
    end
    return data
    end

      # GetDomainSettings
      # Get the domain settings
          # @param settings_service_get_domain_settings_request [SettingsServiceGetDomainSettingsRequest] 
      # @param [Hash] opts the optional parameters
    # @return [SettingsServiceGetDomainSettingsResponse]
    def get_domain_settings(settings_service_get_domain_settings_request, opts = {})
    if @api_client.config.debugging
    @api_client.config.logger.debug 'Calling API: Api::SettingsServiceApi.get_domain_settings ...' # MODIFIED
    end
          # verify the required parameter 'settings_service_get_domain_settings_request' is set
          if @api_client.config.client_side_validation && settings_service_get_domain_settings_request.nil?
          fail ArgumentError, "Missing the required parameter 'settings_service_get_domain_settings_request' when calling Api::SettingsServiceApi.get_domain_settings" # MODIFIED
          end
    # resource path
    local_var_path = '/zitadel.settings.v2.SettingsService/GetDomainSettings'

    # query parameters
    query_params = opts[:query_params] || {}

    # header parameters
    header_params = opts[:header_params] || {}
      # HTTP header 'Accept' (if needed)
      header_params['Accept'] = @api_client.select_header_accept(['application/json']) unless header_params['Accept']
      # HTTP header 'Content-Type'
      content_type = @api_client.select_header_content_type(['application/json'])
      if !content_type.nil?
      header_params['Content-Type'] = content_type
      end

    # form parameters
    form_params = opts[:form_params] || {}

    # http body (model)
    post_body = opts[:debug_body] || @api_client.object_to_http_body(settings_service_get_domain_settings_request)

    # return_type
    return_type = opts[:debug_return_type] || 'SettingsServiceGetDomainSettingsResponse'

    # auth_names
    auth_names = opts[:debug_auth_names] || ['zitadelAccessToken']

    new_options = opts.merge(
    :operation => :"Api::SettingsServiceApi.get_domain_settings", # MODIFIED
    :header_params => header_params,
    :query_params => query_params,
    :form_params => form_params,
    :body => post_body,
    :auth_names => auth_names,
    :return_type => return_type
    )

    data, status_code, headers = @api_client.call_api(:POST, local_var_path, new_options)
    if @api_client.config.debugging
    @api_client.config.logger.debug "API called: Api::SettingsServiceApi#get_domain_settings\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}" # MODIFIED
    end
    return data
    end

      # GetGeneralSettings
      # Get basic information over the instance
          # @param body [Object] 
      # @param [Hash] opts the optional parameters
    # @return [SettingsServiceGetGeneralSettingsResponse]
    def get_general_settings(body = {}, opts = {})
    if @api_client.config.debugging
    @api_client.config.logger.debug 'Calling API: Api::SettingsServiceApi.get_general_settings ...' # MODIFIED
    end
          # verify the required parameter 'body' is set
          if @api_client.config.client_side_validation && body.nil?
          fail ArgumentError, "Missing the required parameter 'body' when calling Api::SettingsServiceApi.get_general_settings" # MODIFIED
          end
    # resource path
    local_var_path = '/zitadel.settings.v2.SettingsService/GetGeneralSettings'

    # query parameters
    query_params = opts[:query_params] || {}

    # header parameters
    header_params = opts[:header_params] || {}
      # HTTP header 'Accept' (if needed)
      header_params['Accept'] = @api_client.select_header_accept(['application/json']) unless header_params['Accept']
      # HTTP header 'Content-Type'
      content_type = @api_client.select_header_content_type(['application/json'])
      if !content_type.nil?
      header_params['Content-Type'] = content_type
      end

    # form parameters
    form_params = opts[:form_params] || {}

    # http body (model)
    post_body = opts[:debug_body] || @api_client.object_to_http_body(body)

    # return_type
    return_type = opts[:debug_return_type] || 'SettingsServiceGetGeneralSettingsResponse'

    # auth_names
    auth_names = opts[:debug_auth_names] || ['zitadelAccessToken']

    new_options = opts.merge(
    :operation => :"Api::SettingsServiceApi.get_general_settings", # MODIFIED
    :header_params => header_params,
    :query_params => query_params,
    :form_params => form_params,
    :body => post_body,
    :auth_names => auth_names,
    :return_type => return_type
    )

    data, status_code, headers = @api_client.call_api(:POST, local_var_path, new_options)
    if @api_client.config.debugging
    @api_client.config.logger.debug "API called: Api::SettingsServiceApi#get_general_settings\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}" # MODIFIED
    end
    return data
    end

      # GetHostedLoginTranslation
      # Get Hosted Login Translation   Returns the translations in the requested locale for the hosted login.  The translations returned are based on the input level specified (system, instance or organization).   If the requested level doesn&#39;t contain all translations, and ignore_inheritance is set to false,  a merging process fallbacks onto the higher levels ensuring all keys in the file have a translation,  which could be in the default language if the one of the locale is missing on all levels.   The etag returned in the response represents the hash of the translations as they are stored on DB  and its reliable only if ignore_inheritance &#x3D; true.   Required permissions:    - &#x60;iam.policy.read&#x60;
          # @param settings_service_get_hosted_login_translation_request [SettingsServiceGetHostedLoginTranslationRequest] 
      # @param [Hash] opts the optional parameters
    # @return [SettingsServiceGetHostedLoginTranslationResponse]
    def get_hosted_login_translation(settings_service_get_hosted_login_translation_request, opts = {})
    if @api_client.config.debugging
    @api_client.config.logger.debug 'Calling API: Api::SettingsServiceApi.get_hosted_login_translation ...' # MODIFIED
    end
          # verify the required parameter 'settings_service_get_hosted_login_translation_request' is set
          if @api_client.config.client_side_validation && settings_service_get_hosted_login_translation_request.nil?
          fail ArgumentError, "Missing the required parameter 'settings_service_get_hosted_login_translation_request' when calling Api::SettingsServiceApi.get_hosted_login_translation" # MODIFIED
          end
    # resource path
    local_var_path = '/zitadel.settings.v2.SettingsService/GetHostedLoginTranslation'

    # query parameters
    query_params = opts[:query_params] || {}

    # header parameters
    header_params = opts[:header_params] || {}
      # HTTP header 'Accept' (if needed)
      header_params['Accept'] = @api_client.select_header_accept(['application/json']) unless header_params['Accept']
      # HTTP header 'Content-Type'
      content_type = @api_client.select_header_content_type(['application/json'])
      if !content_type.nil?
      header_params['Content-Type'] = content_type
      end

    # form parameters
    form_params = opts[:form_params] || {}

    # http body (model)
    post_body = opts[:debug_body] || @api_client.object_to_http_body(settings_service_get_hosted_login_translation_request)

    # return_type
    return_type = opts[:debug_return_type] || 'SettingsServiceGetHostedLoginTranslationResponse'

    # auth_names
    auth_names = opts[:debug_auth_names] || ['zitadelAccessToken']

    new_options = opts.merge(
    :operation => :"Api::SettingsServiceApi.get_hosted_login_translation", # MODIFIED
    :header_params => header_params,
    :query_params => query_params,
    :form_params => form_params,
    :body => post_body,
    :auth_names => auth_names,
    :return_type => return_type
    )

    data, status_code, headers = @api_client.call_api(:POST, local_var_path, new_options)
    if @api_client.config.debugging
    @api_client.config.logger.debug "API called: Api::SettingsServiceApi#get_hosted_login_translation\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}" # MODIFIED
    end
    return data
    end

      # GetLegalAndSupportSettings
      # Get the legal and support settings
          # @param settings_service_get_legal_and_support_settings_request [SettingsServiceGetLegalAndSupportSettingsRequest] 
      # @param [Hash] opts the optional parameters
    # @return [SettingsServiceGetLegalAndSupportSettingsResponse]
    def get_legal_and_support_settings(settings_service_get_legal_and_support_settings_request, opts = {})
    if @api_client.config.debugging
    @api_client.config.logger.debug 'Calling API: Api::SettingsServiceApi.get_legal_and_support_settings ...' # MODIFIED
    end
          # verify the required parameter 'settings_service_get_legal_and_support_settings_request' is set
          if @api_client.config.client_side_validation && settings_service_get_legal_and_support_settings_request.nil?
          fail ArgumentError, "Missing the required parameter 'settings_service_get_legal_and_support_settings_request' when calling Api::SettingsServiceApi.get_legal_and_support_settings" # MODIFIED
          end
    # resource path
    local_var_path = '/zitadel.settings.v2.SettingsService/GetLegalAndSupportSettings'

    # query parameters
    query_params = opts[:query_params] || {}

    # header parameters
    header_params = opts[:header_params] || {}
      # HTTP header 'Accept' (if needed)
      header_params['Accept'] = @api_client.select_header_accept(['application/json']) unless header_params['Accept']
      # HTTP header 'Content-Type'
      content_type = @api_client.select_header_content_type(['application/json'])
      if !content_type.nil?
      header_params['Content-Type'] = content_type
      end

    # form parameters
    form_params = opts[:form_params] || {}

    # http body (model)
    post_body = opts[:debug_body] || @api_client.object_to_http_body(settings_service_get_legal_and_support_settings_request)

    # return_type
    return_type = opts[:debug_return_type] || 'SettingsServiceGetLegalAndSupportSettingsResponse'

    # auth_names
    auth_names = opts[:debug_auth_names] || ['zitadelAccessToken']

    new_options = opts.merge(
    :operation => :"Api::SettingsServiceApi.get_legal_and_support_settings", # MODIFIED
    :header_params => header_params,
    :query_params => query_params,
    :form_params => form_params,
    :body => post_body,
    :auth_names => auth_names,
    :return_type => return_type
    )

    data, status_code, headers = @api_client.call_api(:POST, local_var_path, new_options)
    if @api_client.config.debugging
    @api_client.config.logger.debug "API called: Api::SettingsServiceApi#get_legal_and_support_settings\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}" # MODIFIED
    end
    return data
    end

      # GetLockoutSettings
      # Get the lockout settings
          # @param settings_service_get_lockout_settings_request [SettingsServiceGetLockoutSettingsRequest] 
      # @param [Hash] opts the optional parameters
    # @return [SettingsServiceGetLockoutSettingsResponse]
    def get_lockout_settings(settings_service_get_lockout_settings_request, opts = {})
    if @api_client.config.debugging
    @api_client.config.logger.debug 'Calling API: Api::SettingsServiceApi.get_lockout_settings ...' # MODIFIED
    end
          # verify the required parameter 'settings_service_get_lockout_settings_request' is set
          if @api_client.config.client_side_validation && settings_service_get_lockout_settings_request.nil?
          fail ArgumentError, "Missing the required parameter 'settings_service_get_lockout_settings_request' when calling Api::SettingsServiceApi.get_lockout_settings" # MODIFIED
          end
    # resource path
    local_var_path = '/zitadel.settings.v2.SettingsService/GetLockoutSettings'

    # query parameters
    query_params = opts[:query_params] || {}

    # header parameters
    header_params = opts[:header_params] || {}
      # HTTP header 'Accept' (if needed)
      header_params['Accept'] = @api_client.select_header_accept(['application/json']) unless header_params['Accept']
      # HTTP header 'Content-Type'
      content_type = @api_client.select_header_content_type(['application/json'])
      if !content_type.nil?
      header_params['Content-Type'] = content_type
      end

    # form parameters
    form_params = opts[:form_params] || {}

    # http body (model)
    post_body = opts[:debug_body] || @api_client.object_to_http_body(settings_service_get_lockout_settings_request)

    # return_type
    return_type = opts[:debug_return_type] || 'SettingsServiceGetLockoutSettingsResponse'

    # auth_names
    auth_names = opts[:debug_auth_names] || ['zitadelAccessToken']

    new_options = opts.merge(
    :operation => :"Api::SettingsServiceApi.get_lockout_settings", # MODIFIED
    :header_params => header_params,
    :query_params => query_params,
    :form_params => form_params,
    :body => post_body,
    :auth_names => auth_names,
    :return_type => return_type
    )

    data, status_code, headers = @api_client.call_api(:POST, local_var_path, new_options)
    if @api_client.config.debugging
    @api_client.config.logger.debug "API called: Api::SettingsServiceApi#get_lockout_settings\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}" # MODIFIED
    end
    return data
    end

      # GetLoginSettings
      # Get the login settings
          # @param settings_service_get_login_settings_request [SettingsServiceGetLoginSettingsRequest] 
      # @param [Hash] opts the optional parameters
    # @return [SettingsServiceGetLoginSettingsResponse]
    def get_login_settings(settings_service_get_login_settings_request, opts = {})
    if @api_client.config.debugging
    @api_client.config.logger.debug 'Calling API: Api::SettingsServiceApi.get_login_settings ...' # MODIFIED
    end
          # verify the required parameter 'settings_service_get_login_settings_request' is set
          if @api_client.config.client_side_validation && settings_service_get_login_settings_request.nil?
          fail ArgumentError, "Missing the required parameter 'settings_service_get_login_settings_request' when calling Api::SettingsServiceApi.get_login_settings" # MODIFIED
          end
    # resource path
    local_var_path = '/zitadel.settings.v2.SettingsService/GetLoginSettings'

    # query parameters
    query_params = opts[:query_params] || {}

    # header parameters
    header_params = opts[:header_params] || {}
      # HTTP header 'Accept' (if needed)
      header_params['Accept'] = @api_client.select_header_accept(['application/json']) unless header_params['Accept']
      # HTTP header 'Content-Type'
      content_type = @api_client.select_header_content_type(['application/json'])
      if !content_type.nil?
      header_params['Content-Type'] = content_type
      end

    # form parameters
    form_params = opts[:form_params] || {}

    # http body (model)
    post_body = opts[:debug_body] || @api_client.object_to_http_body(settings_service_get_login_settings_request)

    # return_type
    return_type = opts[:debug_return_type] || 'SettingsServiceGetLoginSettingsResponse'

    # auth_names
    auth_names = opts[:debug_auth_names] || ['zitadelAccessToken']

    new_options = opts.merge(
    :operation => :"Api::SettingsServiceApi.get_login_settings", # MODIFIED
    :header_params => header_params,
    :query_params => query_params,
    :form_params => form_params,
    :body => post_body,
    :auth_names => auth_names,
    :return_type => return_type
    )

    data, status_code, headers = @api_client.call_api(:POST, local_var_path, new_options)
    if @api_client.config.debugging
    @api_client.config.logger.debug "API called: Api::SettingsServiceApi#get_login_settings\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}" # MODIFIED
    end
    return data
    end

      # GetPasswordComplexitySettings
      # Get the password complexity settings
          # @param settings_service_get_password_complexity_settings_request [SettingsServiceGetPasswordComplexitySettingsRequest] 
      # @param [Hash] opts the optional parameters
    # @return [SettingsServiceGetPasswordComplexitySettingsResponse]
    def get_password_complexity_settings(settings_service_get_password_complexity_settings_request, opts = {})
    if @api_client.config.debugging
    @api_client.config.logger.debug 'Calling API: Api::SettingsServiceApi.get_password_complexity_settings ...' # MODIFIED
    end
          # verify the required parameter 'settings_service_get_password_complexity_settings_request' is set
          if @api_client.config.client_side_validation && settings_service_get_password_complexity_settings_request.nil?
          fail ArgumentError, "Missing the required parameter 'settings_service_get_password_complexity_settings_request' when calling Api::SettingsServiceApi.get_password_complexity_settings" # MODIFIED
          end
    # resource path
    local_var_path = '/zitadel.settings.v2.SettingsService/GetPasswordComplexitySettings'

    # query parameters
    query_params = opts[:query_params] || {}

    # header parameters
    header_params = opts[:header_params] || {}
      # HTTP header 'Accept' (if needed)
      header_params['Accept'] = @api_client.select_header_accept(['application/json']) unless header_params['Accept']
      # HTTP header 'Content-Type'
      content_type = @api_client.select_header_content_type(['application/json'])
      if !content_type.nil?
      header_params['Content-Type'] = content_type
      end

    # form parameters
    form_params = opts[:form_params] || {}

    # http body (model)
    post_body = opts[:debug_body] || @api_client.object_to_http_body(settings_service_get_password_complexity_settings_request)

    # return_type
    return_type = opts[:debug_return_type] || 'SettingsServiceGetPasswordComplexitySettingsResponse'

    # auth_names
    auth_names = opts[:debug_auth_names] || ['zitadelAccessToken']

    new_options = opts.merge(
    :operation => :"Api::SettingsServiceApi.get_password_complexity_settings", # MODIFIED
    :header_params => header_params,
    :query_params => query_params,
    :form_params => form_params,
    :body => post_body,
    :auth_names => auth_names,
    :return_type => return_type
    )

    data, status_code, headers = @api_client.call_api(:POST, local_var_path, new_options)
    if @api_client.config.debugging
    @api_client.config.logger.debug "API called: Api::SettingsServiceApi#get_password_complexity_settings\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}" # MODIFIED
    end
    return data
    end

      # GetPasswordExpirySettings
      # Get the password expiry settings
          # @param settings_service_get_password_expiry_settings_request [SettingsServiceGetPasswordExpirySettingsRequest] 
      # @param [Hash] opts the optional parameters
    # @return [SettingsServiceGetPasswordExpirySettingsResponse]
    def get_password_expiry_settings(settings_service_get_password_expiry_settings_request, opts = {})
    if @api_client.config.debugging
    @api_client.config.logger.debug 'Calling API: Api::SettingsServiceApi.get_password_expiry_settings ...' # MODIFIED
    end
          # verify the required parameter 'settings_service_get_password_expiry_settings_request' is set
          if @api_client.config.client_side_validation && settings_service_get_password_expiry_settings_request.nil?
          fail ArgumentError, "Missing the required parameter 'settings_service_get_password_expiry_settings_request' when calling Api::SettingsServiceApi.get_password_expiry_settings" # MODIFIED
          end
    # resource path
    local_var_path = '/zitadel.settings.v2.SettingsService/GetPasswordExpirySettings'

    # query parameters
    query_params = opts[:query_params] || {}

    # header parameters
    header_params = opts[:header_params] || {}
      # HTTP header 'Accept' (if needed)
      header_params['Accept'] = @api_client.select_header_accept(['application/json']) unless header_params['Accept']
      # HTTP header 'Content-Type'
      content_type = @api_client.select_header_content_type(['application/json'])
      if !content_type.nil?
      header_params['Content-Type'] = content_type
      end

    # form parameters
    form_params = opts[:form_params] || {}

    # http body (model)
    post_body = opts[:debug_body] || @api_client.object_to_http_body(settings_service_get_password_expiry_settings_request)

    # return_type
    return_type = opts[:debug_return_type] || 'SettingsServiceGetPasswordExpirySettingsResponse'

    # auth_names
    auth_names = opts[:debug_auth_names] || ['zitadelAccessToken']

    new_options = opts.merge(
    :operation => :"Api::SettingsServiceApi.get_password_expiry_settings", # MODIFIED
    :header_params => header_params,
    :query_params => query_params,
    :form_params => form_params,
    :body => post_body,
    :auth_names => auth_names,
    :return_type => return_type
    )

    data, status_code, headers = @api_client.call_api(:POST, local_var_path, new_options)
    if @api_client.config.debugging
    @api_client.config.logger.debug "API called: Api::SettingsServiceApi#get_password_expiry_settings\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}" # MODIFIED
    end
    return data
    end

      # GetSecuritySettings
      # Get the security settings
          # @param body [Object] 
      # @param [Hash] opts the optional parameters
    # @return [SettingsServiceGetSecuritySettingsResponse]
    def get_security_settings(body = {}, opts = {})
    if @api_client.config.debugging
    @api_client.config.logger.debug 'Calling API: Api::SettingsServiceApi.get_security_settings ...' # MODIFIED
    end
          # verify the required parameter 'body' is set
          if @api_client.config.client_side_validation && body.nil?
          fail ArgumentError, "Missing the required parameter 'body' when calling Api::SettingsServiceApi.get_security_settings" # MODIFIED
          end
    # resource path
    local_var_path = '/zitadel.settings.v2.SettingsService/GetSecuritySettings'

    # query parameters
    query_params = opts[:query_params] || {}

    # header parameters
    header_params = opts[:header_params] || {}
      # HTTP header 'Accept' (if needed)
      header_params['Accept'] = @api_client.select_header_accept(['application/json']) unless header_params['Accept']
      # HTTP header 'Content-Type'
      content_type = @api_client.select_header_content_type(['application/json'])
      if !content_type.nil?
      header_params['Content-Type'] = content_type
      end

    # form parameters
    form_params = opts[:form_params] || {}

    # http body (model)
    post_body = opts[:debug_body] || @api_client.object_to_http_body(body)

    # return_type
    return_type = opts[:debug_return_type] || 'SettingsServiceGetSecuritySettingsResponse'

    # auth_names
    auth_names = opts[:debug_auth_names] || ['zitadelAccessToken']

    new_options = opts.merge(
    :operation => :"Api::SettingsServiceApi.get_security_settings", # MODIFIED
    :header_params => header_params,
    :query_params => query_params,
    :form_params => form_params,
    :body => post_body,
    :auth_names => auth_names,
    :return_type => return_type
    )

    data, status_code, headers = @api_client.call_api(:POST, local_var_path, new_options)
    if @api_client.config.debugging
    @api_client.config.logger.debug "API called: Api::SettingsServiceApi#get_security_settings\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}" # MODIFIED
    end
    return data
    end

      # SetHostedLoginTranslation
      # Set Hosted Login Translation   Sets the input translations at the specified level (instance or organization) for the input language.   Required permissions:    - &#x60;iam.policy.write&#x60;
          # @param settings_service_set_hosted_login_translation_request [SettingsServiceSetHostedLoginTranslationRequest] 
      # @param [Hash] opts the optional parameters
    # @return [SettingsServiceSetHostedLoginTranslationResponse]
    def set_hosted_login_translation(settings_service_set_hosted_login_translation_request, opts = {})
    if @api_client.config.debugging
    @api_client.config.logger.debug 'Calling API: Api::SettingsServiceApi.set_hosted_login_translation ...' # MODIFIED
    end
          # verify the required parameter 'settings_service_set_hosted_login_translation_request' is set
          if @api_client.config.client_side_validation && settings_service_set_hosted_login_translation_request.nil?
          fail ArgumentError, "Missing the required parameter 'settings_service_set_hosted_login_translation_request' when calling Api::SettingsServiceApi.set_hosted_login_translation" # MODIFIED
          end
    # resource path
    local_var_path = '/zitadel.settings.v2.SettingsService/SetHostedLoginTranslation'

    # query parameters
    query_params = opts[:query_params] || {}

    # header parameters
    header_params = opts[:header_params] || {}
      # HTTP header 'Accept' (if needed)
      header_params['Accept'] = @api_client.select_header_accept(['application/json']) unless header_params['Accept']
      # HTTP header 'Content-Type'
      content_type = @api_client.select_header_content_type(['application/json'])
      if !content_type.nil?
      header_params['Content-Type'] = content_type
      end

    # form parameters
    form_params = opts[:form_params] || {}

    # http body (model)
    post_body = opts[:debug_body] || @api_client.object_to_http_body(settings_service_set_hosted_login_translation_request)

    # return_type
    return_type = opts[:debug_return_type] || 'SettingsServiceSetHostedLoginTranslationResponse'

    # auth_names
    auth_names = opts[:debug_auth_names] || ['zitadelAccessToken']

    new_options = opts.merge(
    :operation => :"Api::SettingsServiceApi.set_hosted_login_translation", # MODIFIED
    :header_params => header_params,
    :query_params => query_params,
    :form_params => form_params,
    :body => post_body,
    :auth_names => auth_names,
    :return_type => return_type
    )

    data, status_code, headers = @api_client.call_api(:POST, local_var_path, new_options)
    if @api_client.config.debugging
    @api_client.config.logger.debug "API called: Api::SettingsServiceApi#set_hosted_login_translation\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}" # MODIFIED
    end
    return data
    end

      # SetSecuritySettings
      # Set the security settings
          # @param settings_service_set_security_settings_request [SettingsServiceSetSecuritySettingsRequest] 
      # @param [Hash] opts the optional parameters
    # @return [SettingsServiceSetSecuritySettingsResponse]
    def set_security_settings(settings_service_set_security_settings_request, opts = {})
    if @api_client.config.debugging
    @api_client.config.logger.debug 'Calling API: Api::SettingsServiceApi.set_security_settings ...' # MODIFIED
    end
          # verify the required parameter 'settings_service_set_security_settings_request' is set
          if @api_client.config.client_side_validation && settings_service_set_security_settings_request.nil?
          fail ArgumentError, "Missing the required parameter 'settings_service_set_security_settings_request' when calling Api::SettingsServiceApi.set_security_settings" # MODIFIED
          end
    # resource path
    local_var_path = '/zitadel.settings.v2.SettingsService/SetSecuritySettings'

    # query parameters
    query_params = opts[:query_params] || {}

    # header parameters
    header_params = opts[:header_params] || {}
      # HTTP header 'Accept' (if needed)
      header_params['Accept'] = @api_client.select_header_accept(['application/json']) unless header_params['Accept']
      # HTTP header 'Content-Type'
      content_type = @api_client.select_header_content_type(['application/json'])
      if !content_type.nil?
      header_params['Content-Type'] = content_type
      end

    # form parameters
    form_params = opts[:form_params] || {}

    # http body (model)
    post_body = opts[:debug_body] || @api_client.object_to_http_body(settings_service_set_security_settings_request)

    # return_type
    return_type = opts[:debug_return_type] || 'SettingsServiceSetSecuritySettingsResponse'

    # auth_names
    auth_names = opts[:debug_auth_names] || ['zitadelAccessToken']

    new_options = opts.merge(
    :operation => :"Api::SettingsServiceApi.set_security_settings", # MODIFIED
    :header_params => header_params,
    :query_params => query_params,
    :form_params => form_params,
    :body => post_body,
    :auth_names => auth_names,
    :return_type => return_type
    )

    data, status_code, headers = @api_client.call_api(:POST, local_var_path, new_options)
    if @api_client.config.debugging
    @api_client.config.logger.debug "API called: Api::SettingsServiceApi#set_security_settings\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}" # MODIFIED
    end
    return data
    end
  end
end
