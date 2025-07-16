require 'cgi'

module Zitadel::Client::Api
  class BetaSettingsServiceApi
    def initialize(api_client)
      @api_client = api_client
    end

    private

    attr_accessor :api_client
  end
end
