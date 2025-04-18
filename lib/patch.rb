# frozen_string_literal: true

module OAuth2
  module Strategy
    # noinspection RbsMissingTypeSignature
    class Assertion < Base
      private

      def build_assertion(claims, opts)
        raise ArgumentError, 'encoding_opts must include :algorithm and :key' unless
          opts.is_a?(Hash) && opts.key?(:algorithm) && opts.key?(:key)

        headers = opts[:kid] ? { kid: opts[:kid] } : {}
        JWT.encode(claims, opts[:key], opts[:algorithm], headers)
      end
    end
  end
end
