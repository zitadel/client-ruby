# frozen_string_literal: true

require 'zeitwerk'
require 'warning'
require_relative 'zitadel_inflector'

Warning.ignore(:method_redefined, __dir__)
# Every dry-struct model file re-opens the shared +Types+ helper module and
# re-runs +Dry.Types()+, which re-assigns constants such as +Types::Builder+.
# That is intentional and harmless, but Ruby warns "already initialized
# constant" for each one; silence those for files under this SDK.
Warning.ignore(/already initialized constant/, __dir__)

# Main entrypoint for the Zitadel::Client Ruby SDK.
#
# This module encapsulates all functionality for authenticating with and accessing
# Zitadel's identity and access management APIs.
#
# Usage:
#   require 'zitadel-client'
#
#   client = Zitadel::Client::SomeService.new(...)
#
# For more details, see: https://github.com/zitadel/zitadel-ruby
#
module Zitadel
  # Main entrypoint for the Zitadel::Client Ruby SDK.
  #
  # This module encapsulates all functionality for authenticating with and accessing
  # Zitadel's identity and access management APIs.
  #
  # Usage:
  #   require 'zitadel-client'
  #
  #   client = Zitadel::Client::SomeService.new(...)
  #
  # For more details, see: https://github.com/zitadel/zitadel-ruby
  #
  module Client
  end
end

loader = Zeitwerk::Loader.new
loader.tag = File.basename(__FILE__, '.rb')
loader.inflector = ZitadelInflector.new
loader.push_dir("#{__dir__}/zitadel", namespace: Zitadel)
loader.setup
