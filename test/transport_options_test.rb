# frozen_string_literal: true
# rubocop:disable all

require 'minitest/autorun'
require 'zitadel-client'

describe Zitadel::Client::TransportOptions do
  parallelize_me!

  it 'verify_ssl defaults to true' do
    opts = Zitadel::Client::TransportOptions.builder.build
    _(opts.verify_ssl).must_equal true
  end

  it 'ca_cert_path defaults to nil' do
    opts = Zitadel::Client::TransportOptions.builder.build
    _(opts.ca_cert_path).must_be_nil
  end

  it 'proxy defaults to nil' do
    opts = Zitadel::Client::TransportOptions.builder.build
    _(opts.proxy).must_be_nil
  end

  it 'timeout defaults to 10000ms' do
    opts = Zitadel::Client::TransportOptions.builder.build
    _(opts.timeout).must_equal 10_000
  end

  it 'follow_redirects defaults to true' do
    opts = Zitadel::Client::TransportOptions.builder.build
    _(opts.follow_redirects).must_equal true
  end

  it 'max_redirects defaults to nil' do
    opts = Zitadel::Client::TransportOptions.builder.build
    _(opts.max_redirects).must_be_nil
  end

  it 'user_agent defaults to non-empty string' do
    opts = Zitadel::Client::TransportOptions.builder.build
    _(opts.user_agent).wont_be_nil
    _(opts.user_agent).wont_be_empty
  end

  it 'default_headers defaults to empty map' do
    opts = Zitadel::Client::TransportOptions.builder.build
    _(opts.default_headers).must_be_empty
  end

  it 'inject_request_id defaults to false' do
    opts = Zitadel::Client::TransportOptions.builder.build
    _(opts.inject_request_id).must_equal false
  end

  it 'builder sets all fields' do
    opts = Zitadel::Client::TransportOptions.builder
      .verify_ssl(false)
      .ca_cert_path('/path/to/ca.pem')
      .proxy('http://proxy:8080')
      .timeout(5000)
      .follow_redirects(false)
      .max_redirects(3)
      .user_agent('TestAgent/1.0')
      .default_header('X-Custom', 'value')
      .inject_request_id(true)
      .build

    _(opts.verify_ssl).must_equal false
    _(opts.ca_cert_path).must_equal '/path/to/ca.pem'
    _(opts.proxy).must_equal 'http://proxy:8080'
    _(opts.timeout).must_equal 5000
    _(opts.follow_redirects).must_equal false
    _(opts.max_redirects).must_equal 3
    _(opts.user_agent).must_equal 'TestAgent/1.0'
    _(opts.default_headers).must_equal({ 'X-Custom' => 'value' })
    _(opts.inject_request_id).must_equal true
  end

  it 'follow_redirects defaults to true with null max_redirects' do
    opts = Zitadel::Client::TransportOptions.builder
      .follow_redirects(true)
      .build

    _(opts.follow_redirects).must_equal true
    _(opts.max_redirects).must_be_nil
  end

  it 'invalid proxy URL throws exception' do
    assert_raises(ArgumentError) do
      Zitadel::Client::TransportOptions.builder.proxy('not-a-url').build
    end
  end

  it 'null proxy URL is accepted' do
    opts = Zitadel::Client::TransportOptions.builder.proxy(nil).build
    _(opts.proxy).must_be_nil
  end

  it 'builder methods return the same builder instance' do
    builder = Zitadel::Client::TransportOptions.builder

    _(builder.verify_ssl(true)).must_be_same_as builder
    _(builder.ca_cert_path(nil)).must_be_same_as builder
    _(builder.proxy(nil)).must_be_same_as builder
    _(builder.timeout(nil)).must_be_same_as builder
    _(builder.follow_redirects(true)).must_be_same_as builder
    _(builder.max_redirects(nil)).must_be_same_as builder
    _(builder.user_agent(nil)).must_be_same_as builder
    _(builder.default_header('X-Key', 'val')).must_be_same_as builder
    _(builder.default_headers({})).must_be_same_as builder
    _(builder.inject_request_id(false)).must_be_same_as builder
  end

  it 'accumulates headers from default_header calls' do
    opts = Zitadel::Client::TransportOptions.builder
      .default_header('X-First', 'one')
      .default_header('X-Second', 'two')
      .build

    _(opts.default_headers.size).must_equal 2
    _(opts.default_headers['X-First']).must_equal 'one'
    _(opts.default_headers['X-Second']).must_equal 'two'
  end

  it 'merges headers from default_headers call' do
    opts = Zitadel::Client::TransportOptions.builder
      .default_header('X-First', 'one')
      .default_headers({ 'X-Second' => 'two', 'X-Third' => 'three' })
      .build

    _(opts.default_headers.size).must_equal 3
    _(opts.default_headers['X-First']).must_equal 'one'
    _(opts.default_headers['X-Second']).must_equal 'two'
    _(opts.default_headers['X-Third']).must_equal 'three'
  end

  it 'modifying source map does not affect built options' do
    headers = { 'X-Original' => 'original' }

    opts = Zitadel::Client::TransportOptions.builder
      .default_headers(headers)
      .build

    headers['X-Added'] = 'added'

    _(opts.default_headers.size).must_equal 1
    _(opts.default_headers['X-Original']).must_equal 'original'
    _(opts.default_headers.key?('X-Added')).must_equal false
    _(opts.default_headers).must_be :frozen?
  end

  it 'builder produces independent instances' do
    builder = Zitadel::Client::TransportOptions.builder.verify_ssl(false)
    first = builder.build
    second = builder.build

    _(first.verify_ssl).must_equal second.verify_ssl
    _(first).wont_be_same_as second
  end

  # TimeoutConfigTests

  it 'timeout defaults to 10000ms' do
    # Default TransportOptions applies a 10-second timeout.
    opts = Zitadel::Client::TransportOptions.builder.build
    _(opts.timeout).must_equal 10_000
  end

  it 'timeout can be explicitly set to nil for no timeout' do
    opts = Zitadel::Client::TransportOptions.builder.timeout(nil).build
    _(opts.timeout).must_be_nil
  end

  it 'setting timeout to 5000 is accessible' do
    opts = Zitadel::Client::TransportOptions.builder.timeout(5000).build
    _(opts.timeout).must_equal 5000
  end

  it 'timeout field is named exactly timeout' do
    # Verify via the reader that the field is named :timeout (not :open_timeout or :connection_timeout).
    opts = Zitadel::Client::TransportOptions.builder.timeout(1000).build
    _(opts.timeout).wont_be_nil
    _(opts.timeout).must_equal 1000
  end

  # ProxyConfigTests

  it 'setting proxy URL is preserved on read-back' do
    opts = Zitadel::Client::TransportOptions.builder
      .proxy('http://proxy.example.com:8080')
      .build
    _(opts.proxy).must_equal 'http://proxy.example.com:8080'
  end

  it 'setting proxy is supported on all platforms' do
    # Proxy configuration must not raise on any platform.
    opts = Zitadel::Client::TransportOptions.builder
      .proxy('http://proxy.example.com:8080')
      .build
    _(opts.proxy).must_equal 'http://proxy.example.com:8080'
  end
end
