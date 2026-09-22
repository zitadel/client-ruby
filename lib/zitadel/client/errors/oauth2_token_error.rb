# frozen_string_literal: true

module Zitadel
  module Client
    module Errors
      ##
      # Error for an OAuth2 token endpoint that answered 2xx with a body the SDK
      # cannot use: not a JSON object, or without a non-empty +access_token+.
      class OAuth2TokenError < ::Zitadel::Client::ZitadelError
      end
    end
  end
end
