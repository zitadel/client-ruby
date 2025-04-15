module OAuth2
  module Strategy
    # noinspection RbsMissingTypeSignature
    class Assertion < Base
      private

        def build_assertion(claims, encoding_opts)
          raise ArgumentError.new(message: 'Please provide an encoding_opts hash with :algorithm and :key') if !encoding_opts.is_a?(Hash) || (%i[algorithm key] - encoding_opts.keys).any?
          header_fields = {}
          header_fields[:kid] = encoding_opts[:kid] if encoding_opts[:kid]
          JWT.encode(claims, encoding_opts[:key], encoding_opts[:algorithm], header_fields)
        end
    end
  end
end
