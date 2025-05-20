# frozen_string_literal: true

require 'zeitwerk'
require 'warning'
require_relative 'patch'

Warning.ignore(:method_redefined, __dir__)

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
loader.push_dir("#{__dir__}/zitadel", namespace: Zitadel)
loader.inflector.inflect('version' => 'VERSION')
loader.setup
