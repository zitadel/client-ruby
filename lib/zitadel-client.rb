require 'zeitwerk'

loader = Zeitwerk::Loader.new
loader.inflector.inflect "oidc_service_api" => "OIDCServiceApi"
loader.tag = File.basename(__FILE__, ".rb")
loader.collapse("#{__dir__}/zitadel-client/api/")
loader.collapse("#{__dir__}/zitadel-client/auth/")
loader.collapse("#{__dir__}/zitadel-client/models/")
loader.collapse("#{__dir__}/zitadel-client/utils/")
loader.push_dir("#{__dir__}/zitadel-client", namespace: ZitadelClient)
loader.setup

module ZitadelClient
  class << self
    def configure
      if block_given?
        yield(Configuration.default)
      else
        Configuration.default
      end
    end
  end
end
