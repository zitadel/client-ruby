=begin
#Zitadel SDK

#The Zitadel SDK is a convenience wrapper around the Zitadel APIs to assist you in integrating with your Zitadel environment. This SDK enables you to handle resources, settings, and configurations within the Zitadel platform.

The version of the OpenAPI document: 1.0.0

Generated by: https://openapi-generator.tech
Generator version: 7.13.0

=end

require 'cgi'

module Zitadel::Client::Api
  class BetaTelemetryServiceApi
  attr_accessor :api_client

  def initialize(api_client = ApiClient.default)
  @api_client = api_client
  end
      # ReportBaseInformation
      # ReportBaseInformation is used to report the base information of the ZITADEL system,  including the version, instances, their creation date and domains.  The response contains a report ID to link it to the resource counts or other reports.  The report ID is only valid for the same system ID.
          # @param beta_telemetry_service_report_base_information_request [BetaTelemetryServiceReportBaseInformationRequest] 
      # @param [Hash] opts the optional parameters
    # @return [BetaTelemetryServiceReportBaseInformationResponse]
    def report_base_information(beta_telemetry_service_report_base_information_request, opts = {})
    if @api_client.config.debugging
    @api_client.config.logger.debug 'Calling API: Api::BetaTelemetryServiceApi.report_base_information ...' # MODIFIED
    end
          # verify the required parameter 'beta_telemetry_service_report_base_information_request' is set
          if @api_client.config.client_side_validation && beta_telemetry_service_report_base_information_request.nil?
          fail ArgumentError, "Missing the required parameter 'beta_telemetry_service_report_base_information_request' when calling Api::BetaTelemetryServiceApi.report_base_information" # MODIFIED
          end
    # resource path
    local_var_path = '/zitadel.analytics.v2beta.TelemetryService/ReportBaseInformation'

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
    post_body = opts[:debug_body] || @api_client.object_to_http_body(beta_telemetry_service_report_base_information_request)

    # return_type
    return_type = opts[:debug_return_type] || 'BetaTelemetryServiceReportBaseInformationResponse'

    # auth_names
    auth_names = opts[:debug_auth_names] || ['zitadelAccessToken']

    new_options = opts.merge(
    :operation => :"Api::BetaTelemetryServiceApi.report_base_information", # MODIFIED
    :header_params => header_params,
    :query_params => query_params,
    :form_params => form_params,
    :body => post_body,
    :auth_names => auth_names,
    :return_type => return_type
    )

    data, status_code, headers = @api_client.call_api(:POST, local_var_path, new_options)
    if @api_client.config.debugging
    @api_client.config.logger.debug "API called: Api::BetaTelemetryServiceApi#report_base_information\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}" # MODIFIED
    end
    return data
    end

      # ReportResourceCounts
      # ReportResourceCounts is used to report the resource counts such as amount of organizations  or users per organization and much more.  Since the resource counts can be reported in multiple batches,  the response contains a report ID to continue reporting.  The report ID is only valid for the same system ID.
          # @param beta_telemetry_service_report_resource_counts_request [BetaTelemetryServiceReportResourceCountsRequest] 
      # @param [Hash] opts the optional parameters
    # @return [BetaTelemetryServiceReportResourceCountsResponse]
    def report_resource_counts(beta_telemetry_service_report_resource_counts_request, opts = {})
    if @api_client.config.debugging
    @api_client.config.logger.debug 'Calling API: Api::BetaTelemetryServiceApi.report_resource_counts ...' # MODIFIED
    end
          # verify the required parameter 'beta_telemetry_service_report_resource_counts_request' is set
          if @api_client.config.client_side_validation && beta_telemetry_service_report_resource_counts_request.nil?
          fail ArgumentError, "Missing the required parameter 'beta_telemetry_service_report_resource_counts_request' when calling Api::BetaTelemetryServiceApi.report_resource_counts" # MODIFIED
          end
    # resource path
    local_var_path = '/zitadel.analytics.v2beta.TelemetryService/ReportResourceCounts'

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
    post_body = opts[:debug_body] || @api_client.object_to_http_body(beta_telemetry_service_report_resource_counts_request)

    # return_type
    return_type = opts[:debug_return_type] || 'BetaTelemetryServiceReportResourceCountsResponse'

    # auth_names
    auth_names = opts[:debug_auth_names] || ['zitadelAccessToken']

    new_options = opts.merge(
    :operation => :"Api::BetaTelemetryServiceApi.report_resource_counts", # MODIFIED
    :header_params => header_params,
    :query_params => query_params,
    :form_params => form_params,
    :body => post_body,
    :auth_names => auth_names,
    :return_type => return_type
    )

    data, status_code, headers = @api_client.call_api(:POST, local_var_path, new_options)
    if @api_client.config.debugging
    @api_client.config.logger.debug "API called: Api::BetaTelemetryServiceApi#report_resource_counts\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}" # MODIFIED
    end
    return data
    end
  end
end
