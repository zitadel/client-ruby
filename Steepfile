# frozen_string_literal: true

target :app do
  check 'lib'
  signature 'sig'

  library 'json', 'time', 'date', 'uri', 'pathname', 'net-http', 'tempfile', 'openssl'

  ignore 'lib/zitadel/client/models'
  ignore 'lib/zitadel/client/api'
  ignore 'lib/patch.rb'

  Steep.logger.level = Logger::FATAL
end
