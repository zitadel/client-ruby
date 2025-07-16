require 'cgi'

module Zitadel::Client::Api
  class OIDCServiceApi
    def initialize(api_client)
      @api_client = api_client
    end

    private

    attr_accessor :api_client
  end
end
