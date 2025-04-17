# frozen_string_literal: true

require 'zeitwerk'
require 'oauth2'
require_relative 'patch'

# Main entrypoint for the ZitadelClient Ruby SDK.
#
# This module encapsulates all functionality for authenticating with and accessing
# Zitadel's identity and access management APIs.
#
# Usage:
#   require 'zitadel-client'
#
#   client = ZitadelClient::SomeService.new(...)
#
# For more details, see: https://github.com/zitadel/zitadel-client-ruby
#
module ZitadelClient
end

loader = Zeitwerk::Loader.new
loader.inflector.inflect 'oidc_service_api' => 'OIDCServiceApi'
loader.inflector.inflect('version' => 'VERSION')
loader.inflector.inflect(
  'v2_check_idp_intent' => 'V2CheckIDPIntent',
  'v2_remove_u2_f_response' => 'V2RemoveU2FResponse',
  'v2_add_idp_link_response' => 'V2AddIDPLinkResponse',
  'v2_saml_binding' => 'V2SAMLBinding',
  'user_service_register_u2_f_body' => 'UserServiceRegisterU2FBody',
  'user_service_list_idp_links_body' => 'UserServiceListIDPLinksBody',
  'v2_remove_totp_response' => 'V2RemoveTOTPResponse',
  'v2_totp_factor' => 'V2TOTPFactor',
  'v2_otp_factor' => 'V2OTPFactor',
  'request_challenges_otpsms' => 'RequestChallengesOTPSMS',
  'user_service_add_idp_link_body' => 'UserServiceAddIDPLinkBody',
  'v2_remove_idp_link_response' => 'V2RemoveIDPLinkResponse',
  'v2_verify_totp_registration_response' => 'V2VerifyTOTPRegistrationResponse',
  'v2_redirect_urls' => 'V2RedirectURLs',
  'v2_add_otp_email_response' => 'V2AddOTPEmailResponse',
  'v2_ldap_credentials' => 'V2LDAPCredentials',
  'v2_jwt_config' => 'V2JWTConfig',
  'v2_ldap_attributes' => 'V2LDAPAttributes',
  'v2_user_id_query' => 'V2UserIDQuery',
  'otp_email_send_code' => 'OTPEmailSendCode',
  'v2_idpsaml_access_information' => 'V2IDPSAMLAccessInformation',
  'v2_azure_ad_tenant_type' => 'V2AzureADTenantType',
  'v2_saml_name_id_format' => 'V2SAMLNameIDFormat',
  'v2_web_auth_n_factor' => 'V2WebAuthNFactor',
  'v2_add_otpsms_response' => 'V2AddOTPSMSResponse',
  'user_service_verify_totp_registration_body' => 'UserServiceVerifyTOTPRegistrationBody',
  'user_service_verify_u2_f_registration_body' => 'UserServiceVerifyU2FRegistrationBody',
  'v2_saml_config' => 'V2SAMLConfig',
  'v2_remove_otpsms_response' => 'V2RemoveOTPSMSResponse',
  'v2_idp_config' => 'V2IDPConfig',
  'v2_human_mfa_init_skipped_response' => 'V2HumanMFAInitSkippedResponse',
  'v2_ids_query' => 'V2IDsQuery',
  'v2_idp_link' => 'V2IDPLink',
  'v2_idp_intent' => 'V2IDPIntent',
  'v2_ldap_config' => 'V2LDAPConfig',
  'v2_generic_oidc_config' => 'V2GenericOIDCConfig',
  'v2_in_user_id_query' => 'V2InUserIDQuery',
  'v2_get_idpby_id_response' => 'V2GetIDPByIDResponse',
  'v2_idp_information' => 'V2IDPInformation',
  'v2_idpo_auth_access_information' => 'V2IDPOAuthAccessInformation',
  'v2_remove_otp_email_response' => 'V2RemoveOTPEmailResponse',
  'v2_azure_ad_config' => 'V2AzureADConfig',
  'v2_idp' => 'V2IDP',
  'v2_azure_ad_tenant' => 'V2AzureADTenant',
  'v2_get_user_by_id_response' => 'V2GetUserByIDResponse',
  'oidc_service_create_callback_body' => 'OIDCServiceCreateCallbackBody',
  'v2_register_totp_response' => 'V2RegisterTOTPResponse',
  'v2_verify_u2_f_registration_response' => 'V2VerifyU2FRegistrationResponse',
  'v2_idp_type' => 'V2IDPType',
  'request_challenges_otp_email' => 'RequestChallengesOTPEmail',
  'v2_register_u2_f_response' => 'V2RegisterU2FResponse',
  'v2_idp_state' => 'V2IDPState',
  'v2_o_auth_config' => 'V2OAuthConfig',
  'v2_check_otp' => 'V2CheckOTP',
  'v2_idpldap_access_information' => 'V2IDPLDAPAccessInformation',
  'v2_check_totp' => 'V2CheckTOTP',
  'v2_list_idp_links_response' => 'V2ListIDPLinksResponse',
  'v2_organization_id_query' => 'V2OrganizationIDQuery'
)

loader.tag = File.basename(__FILE__, '.rb')
loader.collapse("#{__dir__}/zitadel-client/api/")
loader.collapse("#{__dir__}/zitadel-client/auth/")
loader.collapse("#{__dir__}/zitadel-client/models/")
loader.collapse("#{__dir__}/zitadel-client/utils/")
loader.push_dir("#{__dir__}/zitadel-client", namespace: ZitadelClient)
loader.setup

module ZitadelClient
end
