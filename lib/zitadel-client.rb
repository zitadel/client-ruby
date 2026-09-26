# rubocop:disable Naming/FileName -- gem-name entrypoint: `require 'zitadel-client'`
# frozen_string_literal: true

# Gem entrypoint matching the gem name (`zitadel-client`), so that
# `require 'zitadel-client'` works. The filename must carry the gem's hyphen,
# which is why Naming/FileName is disabled above (the only place this is done).
#
# Loading is delegated to the Zeitwerk autoloader in zitadel_client.rb; this is
# the single source of truth for wiring the SDK's constant tree.
require_relative 'zitadel_client'
# rubocop:enable Naming/FileName
