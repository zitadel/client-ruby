# frozen_string_literal: true

require 'openssl'

module Zitadel
  module Client
    # Immutable transport options for configuring HTTP connections.
    class TransportOptions
      attr_reader :default_headers, :ca_cert_path, :insecure, :proxy_url

      def initialize(default_headers: {}, ca_cert_path: nil, insecure: false, proxy_url: nil)
        @default_headers = default_headers.dup.freeze
        @ca_cert_path = ca_cert_path&.dup&.freeze
        @insecure = insecure
        @proxy_url = proxy_url&.dup&.freeze
        freeze
      end

      def self.defaults
        new
      end

      # Builds Faraday connection options from these transport options.
      #
      # @return [Hash] connection options for OAuth2::Client
      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def to_connection_opts
        opts = {}
        if insecure
          opts[:ssl] = { verify: false }
        elsif ca_cert_path
          store = OpenSSL::X509::Store.new
          store.set_default_paths
          store.add_file(ca_cert_path)
          opts[:ssl] = { cert_store: store, verify: true }
        end
        opts[:proxy] = proxy_url if proxy_url
        opts[:headers] = default_headers.dup if default_headers.any?
        opts
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    end
  end
end
