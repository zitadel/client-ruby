# frozen_string_literal: true
# rubocop:disable all

require 'test_helper'

describe Zitadel::Client::ValueSerializer do
  parallelize_me!

  describe 'path location' do
    it 'null returns empty string' do
      _(Zitadel::Client::ValueSerializer.serialize(nil, :path, 'string')).must_equal('')
    end

    it 'string returns URL-encoded value' do
      _(Zitadel::Client::ValueSerializer.serialize('hello', :path, 'string')).must_equal('hello')
    end

    it 'string with spaces is URL-encoded' do
      _(Zitadel::Client::ValueSerializer.serialize('hello world', :path, 'string')).must_equal('hello%20world')
    end

    it 'string with slash is URL-encoded' do
      _(Zitadel::Client::ValueSerializer.serialize('a/b', :path, 'string')).must_equal('a%2Fb')
    end

    it 'integer returns string' do
      _(Zitadel::Client::ValueSerializer.serialize(42, :path, 'integer')).must_equal('42')
    end

    it 'boolean true returns true' do
      _(Zitadel::Client::ValueSerializer.serialize(true, :path, 'boolean')).must_equal('true')
    end

    it 'boolean false returns false' do
      _(Zitadel::Client::ValueSerializer.serialize(false, :path, 'boolean')).must_equal('false')
    end
  end

  describe 'query location' do
    it 'null returns nil' do
      _(Zitadel::Client::ValueSerializer.serialize(nil, :query, 'string')).must_be_nil
    end

    it 'string returns as-is' do
      _(Zitadel::Client::ValueSerializer.serialize('hello', :query, 'string')).must_equal('hello')
    end

    it 'integer returns string' do
      _(Zitadel::Client::ValueSerializer.serialize(42, :query, 'integer')).must_equal('42')
    end

    it 'boolean true returns true' do
      _(Zitadel::Client::ValueSerializer.serialize(true, :query, 'boolean')).must_equal('true')
    end

    it 'boolean false returns false' do
      _(Zitadel::Client::ValueSerializer.serialize(false, :query, 'boolean')).must_equal('false')
    end

    it 'array joins with comma by default' do
      _(Zitadel::Client::ValueSerializer.serialize(%w[a b c], :query, 'array')).must_equal('a,b,c')
    end

    it 'array joins with comma for csv' do
      result = Zitadel::Client::ValueSerializer.serialize(%w[a b c], :query, 'array', collection_format: :csv)
      _(result).must_equal('a,b,c')
    end

    it 'array joins with space for ssv' do
      result = Zitadel::Client::ValueSerializer.serialize(%w[a b c], :query, 'array', collection_format: :ssv)
      _(result).must_equal('a b c')
    end

    it 'array joins with tab for tsv' do
      result = Zitadel::Client::ValueSerializer.serialize(%w[a b c], :query, 'array', collection_format: :tsv)
      _(result).must_equal("a\tb\tc")
    end

    it 'array joins with pipe for pipes' do
      result = Zitadel::Client::ValueSerializer.serialize(%w[a b c], :query, 'array', collection_format: :pipes)
      _(result).must_equal('a|b|c')
    end

    it 'array returns list for multi' do
      result = Zitadel::Client::ValueSerializer.serialize(%w[a b c], :query, 'array', collection_format: :multi)
      _(result).must_equal(%w[a b c])
    end

    it 'empty array returns empty string for csv' do
      _(Zitadel::Client::ValueSerializer.serialize([], :query, 'array')).must_equal('')
    end

    it 'empty array returns empty list for multi' do
      _(Zitadel::Client::ValueSerializer.serialize([], :query, 'array', collection_format: :multi)).must_equal([])
    end

    it 'single-element array returns single value' do
      _(Zitadel::Client::ValueSerializer.serialize(['a'], :query, 'array')).must_equal('a')
    end

    it 'array of integers stringifies elements' do
      _(Zitadel::Client::ValueSerializer.serialize([1, 2, 3], :query, 'array')).must_equal('1,2,3')
    end

    it 'array of booleans stringifies elements' do
      _(Zitadel::Client::ValueSerializer.serialize([true, false], :query, 'array')).must_equal('true,false')
    end
  end

  describe 'header location' do
    it 'null returns empty string' do
      _(Zitadel::Client::ValueSerializer.serialize(nil, :header, 'string')).must_equal('')
    end

    it 'string returns as-is' do
      _(Zitadel::Client::ValueSerializer.serialize('hello', :header, 'string')).must_equal('hello')
    end

    it 'integer returns string' do
      _(Zitadel::Client::ValueSerializer.serialize(42, :header, 'integer')).must_equal('42')
    end

    it 'boolean true returns true' do
      _(Zitadel::Client::ValueSerializer.serialize(true, :header, 'boolean')).must_equal('true')
    end

    it 'array joins with comma' do
      _(Zitadel::Client::ValueSerializer.serialize(%w[a b c], :header, 'array')).must_equal('a,b,c')
    end

    it 'empty array joins to empty string' do
      _(Zitadel::Client::ValueSerializer.serialize([], :header, 'array')).must_equal('')
    end

    it 'array of integers stringifies and joins' do
      _(Zitadel::Client::ValueSerializer.serialize([1, 2, 3], :header, 'array')).must_equal('1,2,3')
    end
  end

  describe 'cookie location' do
    it 'string returns as-is' do
      _(Zitadel::Client::ValueSerializer.serialize('hello', :cookie, 'string')).must_equal('hello')
    end

    it 'null returns empty string' do
      _(Zitadel::Client::ValueSerializer.serialize(nil, :cookie, 'string')).must_equal('')
    end
  end

  describe 'form location' do
    it 'null returns empty string' do
      _(Zitadel::Client::ValueSerializer.serialize(nil, :form, 'string')).must_equal('')
    end

    it 'string returns as-is' do
      _(Zitadel::Client::ValueSerializer.serialize('hello', :form, 'string')).must_equal('hello')
    end

    it 'integer returns string' do
      _(Zitadel::Client::ValueSerializer.serialize(42, :form, 'integer')).must_equal('42')
    end

    it 'boolean true returns true' do
      _(Zitadel::Client::ValueSerializer.serialize(true, :form, 'boolean')).must_equal('true')
    end

    it 'boolean false returns false' do
      _(Zitadel::Client::ValueSerializer.serialize(false, :form, 'boolean')).must_equal('false')
    end
  end

  describe 'serialize_styled' do
    describe 'matrix style' do
      it 'scalar returns semicolon-prefixed name=value' do
        result = Zitadel::Client::ValueSerializer.serialize_styled('color', 'blue', :path, 'string', nil, 'matrix', true)
        _(result).must_equal(';color=blue')
      end

      it 'array with explode false joins with comma' do
        result = Zitadel::Client::ValueSerializer.serialize_styled(
          'color', %w[blue black], :path, 'array', nil, 'matrix', false
        )
        _(result).must_equal(';color=blue,black')
      end

      it 'array with explode true repeats name' do
        result = Zitadel::Client::ValueSerializer.serialize_styled(
          'color', %w[blue black], :path, 'array', nil, 'matrix', true
        )
        _(result).must_equal(';color=blue;color=black')
      end

      it 'null returns empty string' do
        result = Zitadel::Client::ValueSerializer.serialize_styled('color', nil, :path, 'string', nil, 'matrix', true)
        _(result).must_equal('')
      end
    end

    describe 'label style' do
      it 'scalar returns dot-prefixed value' do
        result = Zitadel::Client::ValueSerializer.serialize_styled('color', 'blue', :path, 'string', nil, 'label', true)
        _(result).must_equal('.blue')
      end

      it 'array with explode false joins with comma after dot' do
        result = Zitadel::Client::ValueSerializer.serialize_styled(
          'color', %w[blue black], :path, 'array', nil, 'label', false
        )
        _(result).must_equal('.blue,black')
      end

      it 'array with explode true joins with dot separator' do
        result = Zitadel::Client::ValueSerializer.serialize_styled(
          'color', %w[blue black], :path, 'array', nil, 'label', true
        )
        _(result).must_equal('.blue.black')
      end

      it 'null returns empty string' do
        result = Zitadel::Client::ValueSerializer.serialize_styled('color', nil, :path, 'string', nil, 'label', true)
        _(result).must_equal('')
      end
    end

    describe 'spaceDelimited style' do
      it 'array joins with space' do
        result = Zitadel::Client::ValueSerializer.serialize_styled(
          'color', %w[blue black], :query, 'array', nil, 'spaceDelimited', false
        )
        _(result).must_equal('blue black')
      end

      it 'scalar returns stringified value' do
        result = Zitadel::Client::ValueSerializer.serialize_styled(
          'color', 'blue', :query, 'string', nil, 'spaceDelimited', false
        )
        _(result).must_equal('blue')
      end
    end

    describe 'pipeDelimited style' do
      it 'array joins with pipe' do
        result = Zitadel::Client::ValueSerializer.serialize_styled(
          'color', %w[blue black], :query, 'array', nil, 'pipeDelimited', false
        )
        _(result).must_equal('blue|black')
      end

      it 'scalar returns stringified value' do
        result = Zitadel::Client::ValueSerializer.serialize_styled(
          'color', 'blue', :query, 'string', nil, 'pipeDelimited', false
        )
        _(result).must_equal('blue')
      end
    end

    describe 'form style with explode' do
      it 'array with explode false joins with comma' do
        result = Zitadel::Client::ValueSerializer.serialize_styled(
          'color', %w[blue black], :query, 'array', nil, 'form', false
        )
        _(result).must_equal('blue,black')
      end

      it 'array with explode true returns list' do
        result = Zitadel::Client::ValueSerializer.serialize_styled(
          'color', %w[blue black], :query, 'array', nil, 'form', true
        )
        _(result).must_equal(%w[blue black])
      end

      it 'scalar with explode true returns string not list' do
        result = Zitadel::Client::ValueSerializer.serialize_styled(
          'color', 'blue', :query, 'string', nil, 'form', true
        )
        _(result).must_equal('blue')
      end

      it 'single-element array with explode true returns list' do
        result = Zitadel::Client::ValueSerializer.serialize_styled(
          'color', ['blue'], :query, 'array', nil, 'form', true
        )
        _(result).must_equal(['blue'])
      end

      it 'null returns nil for query location' do
        result = Zitadel::Client::ValueSerializer.serialize_styled('color', nil, :query, 'string', nil, 'form', true)
        _(result).must_be_nil
      end
    end

    describe 'simple style backward compatibility' do
      it 'scalar returns stringified value' do
        result = Zitadel::Client::ValueSerializer.serialize_styled('id', '5', :path, 'string', nil, 'simple', false)
        _(result).must_equal('5')
      end

      it 'array joins with comma' do
        result = Zitadel::Client::ValueSerializer.serialize_styled(
          'id', %w[3 4 5], :path, 'array', nil, 'simple', false
        )
        _(result).must_equal('3,4,5')
      end

      it 'null returns empty string' do
        result = Zitadel::Client::ValueSerializer.serialize_styled('id', nil, :path, 'string', nil, 'simple', true)
        _(result).must_equal('')
      end

      it 'scalar URL-encodes for path' do
        result = Zitadel::Client::ValueSerializer.serialize_styled(
          'id', 'hello world', :path, 'string', nil, 'simple', false
        )
        _(result).must_equal('hello%20world')
      end
    end

    describe 'null style falls back to location default' do
      it 'path with null style behaves like simple' do
        result = Zitadel::Client::ValueSerializer.serialize_styled('id', '5', :path, 'string', nil, nil, false)
        _(result).must_equal('5')
      end

      it 'empty style falls back to location default' do
        result = Zitadel::Client::ValueSerializer.serialize_styled('id', '5', :path, 'string', nil, '', false)
        _(result).must_equal('5')
      end
    end
  end

  describe 'serialize_deep_object' do
    it 'basic map returns bracketed keys' do
      result = Zitadel::Client::ValueSerializer.serialize_deep_object('filter', { 'color' => 'blue', 'size' => 'large' })
      _(result['filter[color]']).must_equal('blue')
      _(result['filter[size]']).must_equal('large')
    end

    it 'null returns empty hash' do
      result = Zitadel::Client::ValueSerializer.serialize_deep_object('filter', nil)
      _(result).must_equal({})
    end
  end

  # Cross-language parity tests for path-segment percent-encoding.
  # Every SDK must produce identical encoded strings for these inputs.
  describe 'path encoding parity' do
    it 'ASCII-safe pass-through' do
      _(Zitadel::Client::ValueSerializer.serialize('abc123', :path, 'string')).must_equal('abc123')
    end

    it 'space encoded as %20' do
      _(Zitadel::Client::ValueSerializer.serialize('a b', :path, 'string')).must_equal('a%20b')
    end

    it 'slash encoded' do
      _(Zitadel::Client::ValueSerializer.serialize('a/b', :path, 'string')).must_equal('a%2Fb')
    end

    it 'question mark encoded' do
      _(Zitadel::Client::ValueSerializer.serialize('a?b', :path, 'string')).must_equal('a%3Fb')
    end

    it 'hash encoded' do
      _(Zitadel::Client::ValueSerializer.serialize('a#b', :path, 'string')).must_equal('a%23b')
    end

    it 'comma preserved (sub-delimiter)' do
      _(Zitadel::Client::ValueSerializer.serialize('a,b', :path, 'string')).must_equal('a,b')
    end

    it 'colon preserved (sub-delimiter)' do
      _(Zitadel::Client::ValueSerializer.serialize('a:b', :path, 'string')).must_equal('a:b')
    end

    it 'plus preserved (sub-delimiter)' do
      _(Zitadel::Client::ValueSerializer.serialize('a+b', :path, 'string')).must_equal('a+b')
    end

    it 'tilde preserved (RFC 3986 unreserved)' do
      # '~' is an RFC 3986 unreserved character and must never be
      # percent-encoded. URI.encode_www_form_component emits %7E; the
      # canonical encoding (Java, Kotlin, Node, C#, etc.) keeps a literal '~'.
      _(Zitadel::Client::ValueSerializer.serialize('a~b', :path, 'string')).must_equal('a~b')
      _(Zitadel::Client::ValueSerializer.serialize('~', :path, 'string')).must_equal('~')
    end

    it 'unicode encoded as UTF-8 percent' do
      _(Zitadel::Client::ValueSerializer.serialize('日本', :path, 'string')).must_equal('%E6%97%A5%E6%9C%AC')
    end

    it 'empty string preserved' do
      _(Zitadel::Client::ValueSerializer.serialize('', :path, 'string')).must_equal('')
    end

    it 'null returns empty string in path location' do
      _(Zitadel::Client::ValueSerializer.serialize(nil, :path, 'string')).must_equal('')
    end

    it 'simple style encodes value' do
      result = Zitadel::Client::ValueSerializer.serialize_styled('color', 'a b', :path, 'string', nil, 'simple', false)
      _(result).must_equal('a%20b')
    end

    it 'simple style array encodes each item' do
      result = Zitadel::Client::ValueSerializer.serialize_styled('color', ['a b', 'c?d'], :path, 'array', nil, 'simple', false)
      _(result).must_equal('a%20b,c%3Fd')
    end

    it 'path_array_item_with_reserved_char_is_percent_encoded' do
      # Gap W1 regression: every per-item path value in a styled array
      # must be percent-encoded BEFORE being joined with the structural
      # separator. Otherwise '/', '?', '#', space leak into the URL.
      items = %w[a/b c]
      _(Zitadel::Client::ValueSerializer.serialize_styled('name', items, :path, 'array', nil, 'simple', false))
        .must_equal('a%2Fb,c')
      _(Zitadel::Client::ValueSerializer.serialize_styled('name', items, :path, 'array', nil, 'label', true))
        .must_equal('.a%2Fb.c')
      _(Zitadel::Client::ValueSerializer.serialize_styled('name', items, :path, 'array', nil, 'matrix', false))
        .must_equal(';name=a%2Fb,c')
    end

    it 'matrix style encodes value' do
      result = Zitadel::Client::ValueSerializer.serialize_styled('color', 'a b', :path, 'string', nil, 'matrix', false)
      _(result).must_equal(';color=a%20b')
    end

    it 'label style encodes value' do
      result = Zitadel::Client::ValueSerializer.serialize_styled('color', 'a b', :path, 'string', nil, 'label', false)
      _(result).must_equal('.a%20b')
    end

    it 'query location is not path-encoded' do
      result = Zitadel::Client::ValueSerializer.serialize_styled('color', 'a b', :query, 'string', nil, 'form', false)
      _(result).must_equal('a b')
    end

    it 'empty string path param raises ArgumentError' do
      # Gap W — empty-string path values silently produce malformed
      # URLs like `/pet//details`; reject at serialization time so
      # callers see the real error rather than a downstream 404.
      _(-> {
        Zitadel::Client::ValueSerializer.serialize_styled('id', '', :path, 'string', nil, 'simple', false)
      }).must_raise ArgumentError
    end

    it 'path value is encoded exactly once (no double-encoding)' do
      # path-double-encoding: serialize_styled already percent-encodes the path
      # segment, so the api template must NOT wrap it again. A space must become
      # %20 (never %2520) and a slash %2F (never %252F).
      space = Zitadel::Client::ValueSerializer.serialize_styled('id', 'a b', :path, 'string', nil, 'simple', false)
      _(space).must_equal('a%20b')
      _(space).wont_include('%2520')
      slash = Zitadel::Client::ValueSerializer.serialize_styled('id', 'a/b', :path, 'string', nil, 'simple', false)
      _(slash).must_equal('a%2Fb')
      _(slash).wont_include('%252F')
    end
  end

  # N3/W3 parity: `format: date` path parameters must emit a date-only
  # string (YYYY-MM-DD), not a full ISO datetime. Ruby models
  # `format: date` as `Date`, whose `to_s` already produces YYYY-MM-DD.
  describe 'format:date path parameter emits YYYY-MM-DD' do
    require 'date'

    it 'Date in path returns YYYY-MM-DD' do
      date = Date.new(2024, 1, 15)
      _(Zitadel::Client::ValueSerializer.serialize(date, :path, 'string')).must_equal('2024-01-15')
    end

    it 'Date via serialize_styled simple returns YYYY-MM-DD' do
      date = Date.new(2024, 1, 15)
      result = Zitadel::Client::ValueSerializer.serialize_styled('since', date, :path, 'string', nil, 'simple', false)
      _(result).must_equal('2024-01-15')
    end

    it 'Date at a day/year boundary still emits date-only (no time/offset leak)' do
      # UTC/midnight edge: a date on the year boundary must serialize as a bare
      # YYYY-MM-DD with no time/offset suffix, matching the stringifyDate UTC
      # behaviour of Go/Node/Swift/Dart.
      date = Date.new(2024, 12, 31)
      _(Zitadel::Client::ValueSerializer.serialize(date, :path, 'string')).must_equal('2024-12-31')
    end
  end
end
