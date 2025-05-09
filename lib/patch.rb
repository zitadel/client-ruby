# frozen_string_literal: true

require 'oauth2'

module OAuth2
  module Strategy
    # rubocop:disable Style/Documentation
    module AssertionPatch
      private

      # noinspection RbsMissingTypeSignature
      def build_assertion(claims, opts)
        unless opts.is_a?(Hash) && opts.key?(:algorithm) && opts.key?(:key)
          raise ArgumentError,
                'encoding_opts must include :algorithm and :key'
        end

        headers = opts[:kid] ? { kid: opts[:kid] } : {}
        JWT.encode(claims, opts[:key], opts[:algorithm], headers)
      end
    end
    # rubocop:enable Style/Documentation

    class Assertion < Base
      prepend AssertionPatch
    end
  end
end
