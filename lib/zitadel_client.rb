# frozen_string_literal: true

require 'zeitwerk'
require 'oauth2'
require 'warning'
require_relative 'patch'

Warning.ignore(:method_redefined, __dir__)

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
loader.inflector.inflect('version' => 'VERSION')
loader.tag = File.basename(__FILE__, '.rb')
loader.push_dir("#{__dir__}/zitadel-client", namespace: ZitadelClient)
loader.setup
