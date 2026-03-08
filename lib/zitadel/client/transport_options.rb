# frozen_string_literal: true

require 'openssl'

module Zitadel
  module Client
    # Immutable transport options for configuring HTTP connections.
    #
    # Holds TLS, proxy, and default-header settings that are threaded through
    # every authenticator and OpenID discovery call.
    class TransportOptions
      # @return [Hash{String => String}] frozen default headers sent with every request.
      attr_reader :default_headers

      # @return [String, nil] path to a PEM-encoded CA certificate bundle.
      attr_reader :ca_cert_path

      # @return [Boolean] when true, TLS certificate verification is disabled.
      attr_reader :insecure

      # @return [String, nil] HTTP proxy URL (e.g. "http://proxy:8080").
      attr_reader :proxy_url

      # Creates a new TransportOptions instance.
      #
      # @param default_headers [Hash{String => String}] headers to include in every request.
      # @param ca_cert_path [String, nil] path to a custom CA certificate file.
      # @param insecure [Boolean] whether to skip TLS verification.
      # @param proxy_url [String, nil] HTTP proxy URL.
      # @return [TransportOptions] an immutable transport options instance.
      def initialize(default_headers: {}, ca_cert_path: nil, insecure: false, proxy_url: nil)
        @default_headers = default_headers.dup.freeze
        @ca_cert_path = ca_cert_path&.dup&.freeze
        @insecure = insecure
        @proxy_url = proxy_url&.dup&.freeze
        freeze
      end

      # Returns a TransportOptions instance with all default values.
      #
      # @return [TransportOptions] a default transport options instance.
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
