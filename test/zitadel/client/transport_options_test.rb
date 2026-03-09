# frozen_string_literal: true

require 'test_helper'
require 'minitest/autorun'

module Zitadel
  module Client
    class TransportOptionsTest < Minitest::Test
      FIXTURES_DIR = File.join(__dir__, '..', '..', 'fixtures')

      def test_defaults_returns_empty
        assert_equal({}, TransportOptions.defaults.to_connection_opts)
      end

      def test_insecure_sets_ssl_verify
        opts = TransportOptions.new(insecure: true)
        result = opts.to_connection_opts
        assert_equal({ verify: false }, result[:ssl])
      end

      def test_ca_cert_path_sets_cert_store
        ca_path = File.join(FIXTURES_DIR, 'ca.pem')
        opts = TransportOptions.new(ca_cert_path: ca_path)
        result = opts.to_connection_opts
        assert_instance_of OpenSSL::X509::Store, result[:ssl][:cert_store]
        assert_equal true, result[:ssl][:verify]
      end

      def test_proxy_url_sets_proxy
        opts = TransportOptions.new(proxy_url: 'http://proxy:3128')
        result = opts.to_connection_opts
        assert_equal 'http://proxy:3128', result[:proxy]
      end

      def test_default_headers_sets_headers
        opts = TransportOptions.new(default_headers: { 'X-Custom' => 'value' })
        result = opts.to_connection_opts
        assert_equal({ 'X-Custom' => 'value' }, result[:headers])
      end

      def test_insecure_takes_precedence_over_ca_cert
        ca_path = File.join(FIXTURES_DIR, 'ca.pem')
        opts = TransportOptions.new(insecure: true, ca_cert_path: ca_path)
        result = opts.to_connection_opts
        assert_equal({ verify: false }, result[:ssl])
      end

      def test_frozen
        opts = TransportOptions.defaults
        assert_predicate opts, :frozen?
      end

      def test_defaults_factory
        opts = TransportOptions.defaults
        assert_equal({}, opts.default_headers)
        assert_nil opts.ca_cert_path
        assert_equal false, opts.insecure
        assert_nil opts.proxy_url
      end
    end
  end
end
