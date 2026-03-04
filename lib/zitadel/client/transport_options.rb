# frozen_string_literal: true

module Zitadel
  module Client
    # Immutable transport options for configuring HTTP connections.
    class TransportOptions
      attr_reader :default_headers, :ca_cert_path, :insecure, :proxy_url

      def initialize(default_headers: {}, ca_cert_path: nil, insecure: false, proxy_url: nil)
        @default_headers = default_headers.freeze
        @ca_cert_path = ca_cert_path.freeze
        @insecure = insecure
        @proxy_url = proxy_url.freeze
        freeze
      end

      def self.defaults
        new
      end
    end
  end
end
