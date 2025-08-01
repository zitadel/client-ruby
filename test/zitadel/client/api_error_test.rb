# frozen_string_literal: true

require 'minitest/autorun'

module Zitadel
  module Client
    class ApiErrorTest < Minitest::Test
      # rubocop:disable Minitest/MultipleAssertions
      def test_api_error_attributes
        headers = { 'H' => ['v'] }
        err = ApiError.new(418, headers, 'body')

        assert_kind_of ZitadelError, err
        assert_equal 'Error 418', err.message
        assert_equal 418, err.code
        assert_equal headers, err.response_headers
        assert_equal 'body', err.response_body
      end

      # rubocop:enable Minitest/MultipleAssertions
    end
  end
end
