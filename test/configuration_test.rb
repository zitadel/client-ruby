# frozen_string_literal: true
# rubocop:disable all

require 'test_helper'

describe Zitadel::Client::Configuration do
  before do
    @saved_default = Zitadel::Client::Configuration.default
    Zitadel::Client::Configuration.default = Zitadel::Client::Configuration.builder.build
  end

  after do
    Zitadel::Client::Configuration.default = @saved_default
  end

  it 'builder produces correct defaults' do
    config = Zitadel::Client::Configuration.builder.build

    _(config.base_url).must_equal('https://zitadel.com')
    _(config.default_headers).must_equal({})
  end

  it 'builder returns Builder instance' do
    builder = Zitadel::Client::Configuration.builder

    _(builder).must_be_instance_of(Zitadel::Client::Configuration::Builder)
  end

  it 'builder sets base_url' do
    config = Zitadel::Client::Configuration.builder
      .base_url('https://custom.example.com')
      .build

    _(config.base_url).must_equal('https://custom.example.com')
  end

  it 'builder sets single default header' do
    config = Zitadel::Client::Configuration.builder
      .default_header('Authorization', 'Bearer token123')
      .build

    _(config.default_headers).must_equal({ 'Authorization' => 'Bearer token123' })
  end

  it 'builder sets multiple default headers' do
    config = Zitadel::Client::Configuration.builder
      .default_headers({
        'Authorization' => 'Bearer token123',
        'X-Custom' => 'value'
      })
      .build

    _(config.default_headers).must_equal({
      'Authorization' => 'Bearer token123',
      'X-Custom' => 'value'
    })
  end

  it 'builder accumulates headers' do
    config = Zitadel::Client::Configuration.builder
      .default_header('X-First', 'one')
      .default_header('X-Second', 'two')
      .default_headers({ 'X-Third' => 'three' })
      .build

    _(config.default_headers.size).must_equal(3)
    _(config.default_headers['X-First']).must_equal('one')
    _(config.default_headers['X-Second']).must_equal('two')
    _(config.default_headers['X-Third']).must_equal('three')
  end

  it 'builder sets all fields' do
    config = Zitadel::Client::Configuration.builder
      .base_url('https://api.example.com')
      .default_header('Authorization', 'Bearer token')
      .default_headers({ 'X-Custom' => 'value' })
      .build

    _(config.base_url).must_equal('https://api.example.com')
    _(config.default_headers).must_equal({
      'Authorization' => 'Bearer token',
      'X-Custom' => 'value'
    })
  end

  it 'server resolves URL with default variables' do
    server = Zitadel::Client::ServerConfiguration.new(
      url_template: 'https://{env}.example.com/api/{version}',
      description: 'Test server',
      variables: {
        'env' => Zitadel::Client::ServerVariable.new(
          default_value: 'api',
          enum_values: %w[api staging]
        ),
        'version' => Zitadel::Client::ServerVariable.new(
          default_value: 'v3',
          enum_values: %w[v2 v3]
        )
      }
    )

    config = Zitadel::Client::Configuration.builder
      .server(server)
      .build

    _(config.base_url).must_equal('https://api.example.com/api/v3')
  end

  it 'server resolves URL with variable overrides' do
    server = Zitadel::Client::ServerConfiguration.new(
      url_template: 'https://{env}.example.com/api/{version}',
      variables: {
        'env' => Zitadel::Client::ServerVariable.new(
          default_value: 'api',
          enum_values: %w[api staging]
        ),
        'version' => Zitadel::Client::ServerVariable.new(
          default_value: 'v3',
          enum_values: %w[v2 v3]
        )
      }
    )

    config = Zitadel::Client::Configuration.builder
      .server(server, { 'env' => 'staging', 'version' => 'v2' })
      .build

    _(config.base_url).must_equal('https://staging.example.com/api/v2')
  end

  it 'invalid enum value raises' do
    server = Zitadel::Client::ServerConfiguration.new(
      url_template: 'https://{env}.example.com',
      variables: {
        'env' => Zitadel::Client::ServerVariable.new(
          default_value: 'api',
          enum_values: %w[api staging]
        )
      }
    )

    _(proc {
      Zitadel::Client::Configuration.builder
        .server(server, { 'env' => 'invalid' })
        .build
    }).must_raise(ArgumentError)
  end

  it 'base_url overrides server' do
    server = Zitadel::Client::ServerConfiguration.new(
      url_template: 'https://api.example.com'
    )

    config = Zitadel::Client::Configuration.builder
      .server(server)
      .base_url('https://override.example.com')
      .build

    _(config.base_url).must_equal('https://override.example.com')
  end

  it 'default returns an instance' do
    config = Zitadel::Client::Configuration.default

    _(config).must_be_instance_of(Zitadel::Client::Configuration)
    _(config.base_url).must_equal('https://zitadel.com')
  end

  it 'default returns the same instance' do
    first = Zitadel::Client::Configuration.default
    second = Zitadel::Client::Configuration.default

    _(first).must_be_same_as(second)
  end

  it 'setting default changes the default' do
    custom = Zitadel::Client::Configuration.builder
      .base_url('https://custom.example.com')
      .build

    Zitadel::Client::Configuration.default = custom

    _(Zitadel::Client::Configuration.default).must_be_same_as(custom)
    _(Zitadel::Client::Configuration.default.base_url).must_equal('https://custom.example.com')
  end

  it 'builder produces independent instances' do
    builder = Zitadel::Client::Configuration.builder
      .base_url('https://example.com')
    first = builder.build
    second = builder.build

    _(first).wont_be_same_as(second)
    _(first.base_url).must_equal(second.base_url)
  end

  it 'configuration is frozen' do
    config = Zitadel::Client::Configuration.builder
      .default_header('X-Key', 'value')
      .build

    _(config).must_be(:frozen?)
    _(config.default_headers).must_be(:frozen?)
  end

  it 'builder is fluent' do
    builder = Zitadel::Client::Configuration.builder

    _(builder.base_url('https://example.com')).must_be_same_as(builder)
    _(builder.default_header('X-Key', 'value')).must_be_same_as(builder)
    _(builder.default_headers({ 'X-Other' => 'val' })).must_be_same_as(builder)

    server = Zitadel::Client::ServerConfiguration.new(url_template: 'https://example.com')
    _(builder.server(server)).must_be_same_as(builder)
  end
end
