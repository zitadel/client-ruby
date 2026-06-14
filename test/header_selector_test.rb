# frozen_string_literal: true
# rubocop:disable all

require 'test_helper'
require 'zitadel/client/header_selector'

describe Zitadel::Client::HeaderSelector do
  parallelize_me!

  before do
    @header_selector = Zitadel::Client::HeaderSelector.new
  end

  describe '#json_mime?' do
    it 'returns true for application/json' do
      _(@header_selector.json_mime?('application/json')).must_equal(true)
    end

    it 'returns true for application/json with charset' do
      _(@header_selector.json_mime?('application/json; charset=UTF-8')).must_equal(true)
    end

    it 'returns true for uppercase APPLICATION/JSON (case insensitive)' do
      _(@header_selector.json_mime?('APPLICATION/JSON')).must_equal(true)
    end

    it 'returns true for vendor JSON types' do
      _(@header_selector.json_mime?('application/vnd.api+json')).must_equal(true)
      _(@header_selector.json_mime?('application/vnd.company+json')).must_equal(true)
      _(@header_selector.json_mime?('application/hal+json')).must_equal(true)
    end

    it 'returns false for text/html' do
      _(@header_selector.json_mime?('text/html')).must_equal(false)
    end

    it 'returns false for application/xml' do
      _(@header_selector.json_mime?('application/xml')).must_equal(false)
    end

    it 'returns false for application/octet-stream' do
      _(@header_selector.json_mime?('application/octet-stream')).must_equal(false)
    end

    it 'returns false for nil' do
      _(@header_selector.json_mime?(nil)).must_equal(false)
    end

    it 'returns false for empty string' do
      _(@header_selector.json_mime?('')).must_equal(false)
    end
  end

  describe '#select_headers' do
    it 'sets Accept header when accepts provided' do
      headers = @header_selector.select_headers(
        ['application/json'],
        'application/json',
        false
      )
      _(headers['Accept']).must_equal('application/json')
    end

    it 'does not set Accept header when accepts empty' do
      headers = @header_selector.select_headers(
        [],
        'application/json',
        false
      )
      _(headers['Accept']).must_be_nil
    end

    it 'sets Content-Type header when not multipart' do
      headers = @header_selector.select_headers(
        ['application/json'],
        'application/json',
        false
      )
      _(headers['Content-Type']).must_equal('application/json')
    end

    it 'does not set Content-Type header when multipart' do
      headers = @header_selector.select_headers(
        ['application/json'],
        'application/json',
        true
      )
      _(headers['Content-Type']).must_be_nil
    end

    it 'defaults Content-Type to application/json when empty' do
      headers = @header_selector.select_headers(
        ['application/json'],
        '',
        false
      )
      _(headers['Content-Type']).must_equal('application/json')
    end

    it 'defaults Content-Type to application/json when nil' do
      headers = @header_selector.select_headers(
        ['application/json'],
        nil,
        false
      )
      _(headers['Content-Type']).must_equal('application/json')
    end

    it 'returns single accept as-is' do
      headers = @header_selector.select_headers(
        ['application/json'],
        'application/json',
        false
      )
      _(headers['Accept']).must_equal('application/json')
    end

    it 'returns single non-JSON accept as-is' do
      headers = @header_selector.select_headers(
        ['text/html'],
        'application/json',
        false
      )
      _(headers['Accept']).must_equal('text/html')
    end

    it 'joins media types in declaration order' do
      headers = @header_selector.select_headers(
        %w[image/jpeg image/png application/json],
        'application/json',
        false
      )
      _(headers['Accept']).must_equal('image/jpeg, image/png, application/json')
    end

    it 'does not reorder or prioritize JSON types' do
      headers = @header_selector.select_headers(
        %w[text/html application/vnd.api+json application/json],
        'application/json',
        false
      )
      _(headers['Accept']).must_equal('text/html, application/vnd.api+json, application/json')
    end

    it 'filters out empty entries' do
      headers = @header_selector.select_headers(
        ['', 'application/json', nil],
        'application/json',
        false
      )
      _(headers['Accept']).must_equal('application/json')
    end
  end

  describe '#select_accept_header (private)' do
    it 'returns nil for nil input' do
      _(@header_selector.send(:select_accept_header, nil)).must_be_nil
    end

    it 'returns empty string when all entries are filtered out' do
      _(@header_selector.send(:select_accept_header, ['', nil])).must_equal('')
    end

    it 'returns empty string for empty array' do
      _(@header_selector.send(:select_accept_header, [])).must_equal('')
    end

    it 'returns single accept as-is' do
      _(@header_selector.send(:select_accept_header, ['application/json'])).must_equal('application/json')
    end

    it 'returns single non-JSON accept as-is' do
      _(@header_selector.send(:select_accept_header, ['text/html'])).must_equal('text/html')
    end

    it 'joins media types in declaration order with ", "' do
      result = @header_selector.send(:select_accept_header, %w[image/jpeg image/png application/json])
      _(result).must_equal('image/jpeg, image/png, application/json')
    end

    it 'does not reorder or apply quality weights' do
      result = @header_selector.send(:select_accept_header, %w[text/html text/plain])
      _(result).must_equal('text/html, text/plain')
    end
  end
end
