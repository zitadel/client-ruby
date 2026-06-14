# frozen_string_literal: true
# rubocop:disable all

require 'minitest/autorun'
require 'json'
require 'stringio'
require 'zlib'
require 'zitadel-client'

describe Zitadel::Client::DefaultApiClient do
  parallelize_me!

  def stub_connection(stubs)
    Faraday.new('http://localhost') { |f| f.adapter :test, stubs }
  end

  it 'sends GET request and returns response' do
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/echo') { [200, { 'content-type' => 'application/json' }, '{"method":"GET"}'] }
    end
    client = Zitadel::Client::DefaultApiClient.new
    client.stub(:build_connection, stub_connection(stubs)) do
      response = client.send_request('GET', 'http://localhost/echo', {}, nil)
      _(response.status_code).must_equal 200
      body = JSON.parse(response.body)
      _(body['method']).must_equal 'GET'
    end
    stubs.verify_stubbed_calls
  end

  it 'sends POST with JSON body' do
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.post('/echo') { [200, {}, '{"method":"POST","body":"{key}"}'] }
    end
    client = Zitadel::Client::DefaultApiClient.new
    client.stub(:build_connection, stub_connection(stubs)) do
      headers = { 'Content-Type' => 'application/json' }
      response = client.send_request('POST', 'http://localhost/echo', headers, '{"key":"value"}')
      _(response.status_code).must_equal 200
      _(response.body).must_include 'POST'
      _(response.body).must_include 'key'
    end
    stubs.verify_stubbed_calls
  end

  it 'returns response headers' do
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/echo') { [200, { 'x-test-header' => 'test-value' }, 'ok'] }
    end
    client = Zitadel::Client::DefaultApiClient.new
    client.stub(:build_connection, stub_connection(stubs)) do
      response = client.send_request('GET', 'http://localhost/echo', {}, nil)
      _(response.headers['x-test-header']).must_equal 'test-value'
    end
    stubs.verify_stubbed_calls
  end

  it 'returns non-2xx status code' do
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/not-found') { [404, {}, 'not found'] }
    end
    client = Zitadel::Client::DefaultApiClient.new
    client.stub(:build_connection, stub_connection(stubs)) do
      response = client.send_request('GET', 'http://localhost/not-found', {}, nil)
      _(response.status_code).must_equal 404
      _(response.body).must_equal 'not found'
    end
    stubs.verify_stubbed_calls
  end

  it 'sends PUT request' do
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.put('/echo') { [200, {}, '{"method":"PUT"}'] }
    end
    client = Zitadel::Client::DefaultApiClient.new
    client.stub(:build_connection, stub_connection(stubs)) do
      response = client.send_request('PUT', 'http://localhost/echo', {}, 'update')
      _(response.status_code).must_equal 200
      _(response.body).must_include 'PUT'
    end
    stubs.verify_stubbed_calls
  end

  it 'sends DELETE request' do
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.delete('/echo') { [200, {}, '{"method":"DELETE"}'] }
    end
    client = Zitadel::Client::DefaultApiClient.new
    client.stub(:build_connection, stub_connection(stubs)) do
      response = client.send_request('DELETE', 'http://localhost/echo', {}, nil)
      _(response.status_code).must_equal 200
      _(response.body).must_include 'DELETE'
    end
    stubs.verify_stubbed_calls
  end

  it 'returns JSON body for vendor JSON content type' do
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/vendor-json') do
        [200, { 'content-type' => 'application/vnd.api+json' }, '{"format":"vendor"}']
      end
    end
    client = Zitadel::Client::DefaultApiClient.new
    client.stub(:build_connection, stub_connection(stubs)) do
      response = client.send_request('GET', 'http://localhost/vendor-json', {}, nil)
      _(response.status_code).must_equal 200
      body = JSON.parse(response.body)
      _(body['format']).must_equal 'vendor'
    end
    stubs.verify_stubbed_calls
  end

  it 'joins multi-value response headers' do
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/multi-header') do
        [200, { 'x-custom-value' => 'val1, val2' }, 'ok']
      end
    end
    client = Zitadel::Client::DefaultApiClient.new
    client.stub(:build_connection, stub_connection(stubs)) do
      response = client.send_request('GET', 'http://localhost/multi-header', {}, nil)
      _(response.status_code).must_equal 200
      _(response.headers['x-custom-value']).must_include 'val1'
      _(response.headers['x-custom-value']).must_include 'val2'
    end
    stubs.verify_stubbed_calls
  end

  it 'injects custom User-Agent header' do
    captured_ua = nil
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/test') do |env|
        captured_ua = env.request_headers['User-Agent']
        [200, {}, '{}']
      end
    end
    transport = Zitadel::Client::TransportOptions.builder.user_agent('MyApp/1.0').build
    client = Zitadel::Client::DefaultApiClient.new(transport)
    client.stub(:build_connection, stub_connection(stubs)) do
      client.send_request('GET', 'http://localhost/test', {}, nil)
    end
    _(captured_ua).must_equal 'MyApp/1.0'
    stubs.verify_stubbed_calls
  end

  it 'injects default User-Agent when not explicitly set' do
    captured_ua = nil
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/test') do |env|
        captured_ua = env.request_headers['User-Agent']
        [200, {}, '{}']
      end
    end
    client = Zitadel::Client::DefaultApiClient.new
    client.stub(:build_connection, stub_connection(stubs)) do
      client.send_request('GET', 'http://localhost/test', {}, nil)
    end
    _(captured_ua).wont_be_nil
    _(captured_ua).wont_be_empty
    stubs.verify_stubbed_calls
  end

  it 'injects X-Request-ID when enabled' do
    captured_id = nil
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/test') do |env|
        captured_id = env.request_headers['X-Request-ID']
        [200, {}, '{}']
      end
    end
    transport = Zitadel::Client::TransportOptions.builder.inject_request_id(true).build
    client = Zitadel::Client::DefaultApiClient.new(transport)
    client.stub(:build_connection, stub_connection(stubs)) do
      client.send_request('GET', 'http://localhost/test', {}, nil)
    end
    _(captured_id).wont_be_nil
    _(captured_id).must_match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/)
    stubs.verify_stubbed_calls
  end

  it 'does not inject X-Request-ID when disabled' do
    captured_headers = nil
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/test') do |env|
        captured_headers = env.request_headers
        [200, {}, '{}']
      end
    end
    transport = Zitadel::Client::TransportOptions.builder.inject_request_id(false).build
    client = Zitadel::Client::DefaultApiClient.new(transport)
    client.stub(:build_connection, stub_connection(stubs)) do
      client.send_request('GET', 'http://localhost/test', {}, nil)
    end
    _(captured_headers).wont_be_nil
    _(captured_headers.key?('X-Request-ID')).must_equal false
    stubs.verify_stubbed_calls
  end

  it 'does not override caller-provided X-Request-ID' do
    captured_id = nil
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/test') do |env|
        captured_id = env.request_headers['X-Request-ID']
        [200, {}, '{}']
      end
    end
    transport = Zitadel::Client::TransportOptions.builder.inject_request_id(true).build
    client = Zitadel::Client::DefaultApiClient.new(transport)
    client.stub(:build_connection, stub_connection(stubs)) do
      client.send_request('GET', 'http://localhost/test', { 'X-Request-ID' => 'caller-id' }, nil)
    end
    _(captured_id).must_equal 'caller-id'
    stubs.verify_stubbed_calls
  end

  it 'generates unique X-Request-ID per request' do
    captured_ids = []
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/test') do |env|
        captured_ids << env.request_headers['X-Request-ID']
        [200, {}, '{}']
      end
      stub.get('/test') do |env|
        captured_ids << env.request_headers['X-Request-ID']
        [200, {}, '{}']
      end
    end
    transport = Zitadel::Client::TransportOptions.builder.inject_request_id(true).build
    client = Zitadel::Client::DefaultApiClient.new(transport)
    client.stub(:build_connection, stub_connection(stubs)) do
      client.send_request('GET', 'http://localhost/test', {}, nil)
      client.send_request('GET', 'http://localhost/test', {}, nil)
    end
    _(captured_ids.length).must_equal 2
    _(captured_ids[0]).wont_equal captured_ids[1]
  end

  it 'includes transport-level default headers' do
    captured_value = nil
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/test') do |env|
        captured_value = env.request_headers['X-Custom']
        [200, {}, '{}']
      end
    end
    transport = Zitadel::Client::TransportOptions.builder.default_header('X-Custom', 'custom-value').build
    client = Zitadel::Client::DefaultApiClient.new(transport)
    client.stub(:build_connection, stub_connection(stubs)) do
      client.send_request('GET', 'http://localhost/test', {}, nil)
    end
    _(captured_value).must_equal 'custom-value'
    stubs.verify_stubbed_calls
  end

  it 'caller headers override transport default headers' do
    captured_accept = nil
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/test') do |env|
        captured_accept = env.request_headers['Accept']
        [200, {}, '{}']
      end
    end
    transport = Zitadel::Client::TransportOptions.builder.default_header('Accept', 'text/plain').build
    client = Zitadel::Client::DefaultApiClient.new(transport)
    client.stub(:build_connection, stub_connection(stubs)) do
      client.send_request('GET', 'http://localhost/test', { 'Accept' => 'application/json' }, nil)
    end
    _(captured_accept).must_equal 'application/json'
    stubs.verify_stubbed_calls
  end

  # ── Multipart filename sanitization (Gap F) ──

  it 'rejects multipart filename containing CRLF (header injection)' do
    require 'stringio'
    client = Zitadel::Client::DefaultApiClient.new
    io = StringIO.new('payload')
    io.define_singleton_method(:path) { "a\r\nX-Injected: yes" }
    assert_raises(ArgumentError) do
      client.send_request('POST', 'http://localhost/upload', {}, { 'file' => io })
    end
  end

  it 'rejects multipart filename containing NUL byte' do
    require 'stringio'
    client = Zitadel::Client::DefaultApiClient.new
    io = StringIO.new('payload')
    io.define_singleton_method(:path) { "a\0b.txt" }
    assert_raises(ArgumentError) do
      client.send_request('POST', 'http://localhost/upload', {}, { 'file' => io })
    end
  end

  it 'backslash-escapes quotes and backslashes in multipart filename' do
    captured_body = nil
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.post('/upload') do |env|
        captured_body = env.body
        [200, {}, '{}']
      end
    end
    require 'stringio'
    io = StringIO.new('payload')
    io.define_singleton_method(:path) { 'a"b.txt' }
    client = Zitadel::Client::DefaultApiClient.new
    client.stub(:build_connection, stub_connection(stubs)) do
      client.send_request('POST', 'http://localhost/upload', {}, { 'file' => io })
    end
    _(captured_body.to_s).must_include 'filename="a\\"b.txt"'
    stubs.verify_stubbed_calls
  end

  it 'emits RFC 5987 filename* for non-ASCII multipart filenames' do
    captured_body = nil
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.post('/upload') do |env|
        captured_body = env.body
        [200, {}, '{}']
      end
    end
    require 'stringio'
    io = StringIO.new('payload')
    io.define_singleton_method(:path) { '日本.pdf' }
    client = Zitadel::Client::DefaultApiClient.new
    client.stub(:build_connection, stub_connection(stubs)) do
      client.send_request('POST', 'http://localhost/upload', {}, { 'file' => io })
    end
    body_str = captured_body.to_s.dup.force_encoding(Encoding::ASCII_8BIT)
    _(body_str).must_include "filename*=UTF-8''%E6%97%A5%E6%9C%AC.pdf"
    stubs.verify_stubbed_calls
  end

  # ── Non-ASCII multipart field name preserved as UTF-8 (canonical #5) ──
  #
  # A multipart form field NAME containing non-ASCII characters must be
  # emitted verbatim as UTF-8 bytes in the Content-Disposition `name="..."`
  # parameter — not transliterated to '?', not stripped to ASCII. The field
  # name is interpolated raw (after CR/LF/NUL rejection and quote escaping)
  # and the part is built as binary, so the UTF-8 bytes survive intact.
  it 'preserves a non-ASCII multipart field name as UTF-8' do
    captured_body = nil
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.post('/upload') do |env|
        captured_body = env.body
        [200, {}, '{}']
      end
    end
    client = Zitadel::Client::DefaultApiClient.new
    client.stub(:build_connection, stub_connection(stubs)) do
      # 'café' is a plain scalar form field whose NAME is non-ASCII.
      client.send_request('POST', 'http://localhost/upload', {}, { 'café' => 'value' })
    end
    body_str = captured_body.to_s.dup.force_encoding(Encoding::UTF_8)
    _(body_str).must_include 'name="café"'
    # The raw UTF-8 bytes for 'é' (0xC3 0xA9) must be present unmangled.
    body_bytes = captured_body.to_s.dup.force_encoding(Encoding::ASCII_8BIT)
    _(body_bytes).must_include 'caf'.b + "\xC3\xA9".b
    _(body_bytes).wont_include 'name="caf?"'.b
    stubs.verify_stubbed_calls
  end

  # ── Per-part MIME sniffing (Gap J) ──

  it 'sets image/png Content-Type for .png upload' do
    captured_body = nil
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.post('/upload') do |env|
        captured_body = env.body
        [200, {}, '{}']
      end
    end
    require 'stringio'
    io = StringIO.new("\x89PNG\r\n".b)
    io.define_singleton_method(:path) { 'pic.png' }
    client = Zitadel::Client::DefaultApiClient.new
    client.stub(:build_connection, stub_connection(stubs)) do
      client.send_request('POST', 'http://localhost/upload', {}, { 'file' => io })
    end
    _(captured_body.to_s).must_include 'Content-Type: image/png'
    stubs.verify_stubbed_calls
  end

  it 'sets application/pdf for .pdf upload' do
    captured_body = nil
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.post('/upload') do |env|
        captured_body = env.body
        [200, {}, '{}']
      end
    end
    require 'stringio'
    io = StringIO.new('PDF-bytes')
    io.define_singleton_method(:path) { 'doc.pdf' }
    client = Zitadel::Client::DefaultApiClient.new
    client.stub(:build_connection, stub_connection(stubs)) do
      client.send_request('POST', 'http://localhost/upload', {}, { 'file' => io })
    end
    _(captured_body.to_s).must_include 'Content-Type: application/pdf'
    stubs.verify_stubbed_calls
  end

  it 'falls back to application/octet-stream for unknown extension' do
    captured_body = nil
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.post('/upload') do |env|
        captured_body = env.body
        [200, {}, '{}']
      end
    end
    require 'stringio'
    io = StringIO.new('bytes')
    io.define_singleton_method(:path) { 'blob.xyzunknown' }
    client = Zitadel::Client::DefaultApiClient.new
    client.stub(:build_connection, stub_connection(stubs)) do
      client.send_request('POST', 'http://localhost/upload', {}, { 'file' => io })
    end
    _(captured_body.to_s).must_include 'Content-Type: application/octet-stream'
    stubs.verify_stubbed_calls
  end

  # ── Response charset decoding (Gap H) ──

  it 'decodes ISO-8859-1 response body to UTF-8' do
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/latin1') do
        [200, { 'content-type' => 'text/plain; charset=ISO-8859-1' }, "\xE9".b]
      end
    end
    client = Zitadel::Client::DefaultApiClient.new
    client.stub(:build_connection, stub_connection(stubs)) do
      response = client.send_request('GET', 'http://localhost/latin1', {}, nil)
      _(response.body.encoding).must_equal Encoding::UTF_8
      _(response.body).must_equal 'é'
    end
    stubs.verify_stubbed_calls
  end

  it 'defaults to UTF-8 when no charset is given' do
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/no-charset') do
        [200, { 'content-type' => 'text/plain' }, 'héllo']
      end
    end
    client = Zitadel::Client::DefaultApiClient.new
    client.stub(:build_connection, stub_connection(stubs)) do
      response = client.send_request('GET', 'http://localhost/no-charset', {}, nil)
      _(response.body).must_equal 'héllo'
    end
    stubs.verify_stubbed_calls
  end

  it 'falls back to UTF-8 for unknown charset without raising' do
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/bogus') do
        [200, { 'content-type' => 'text/plain; charset=not-a-real-charset' }, 'hello']
      end
    end
    client = Zitadel::Client::DefaultApiClient.new
    client.stub(:build_connection, stub_connection(stubs)) do
      response = client.send_request('GET', 'http://localhost/bogus', {}, nil)
      _(response.body).must_equal 'hello'
    end
    stubs.verify_stubbed_calls
  end

  # ── Proxy authentication (#29) ──
  #
  # The test fixture Squid config does NOT enable basic auth, so any
  # proxy-with-credentials request will succeed at the proxy level just
  # like an unauthenticated request. We assert that the userinfo portion
  # of the proxy URL is accepted and forwarded to Faraday's proxy config
  # without raising; full end-to-end basic-auth verification is skipped
  # because the fixture Squid lacks auth_param config.
  it 'accepts proxy URL with basic-auth userinfo (skips if Squid lacks auth)' do
    skip 'Squid fixture has no auth_param basic configuration'
  end

  it 'parses proxy URL with userinfo without raising' do
    transport = Zitadel::Client::TransportOptions.builder
      .proxy('http://user:pass@proxy.example.com:3128')
      .build
    _(transport.proxy).must_equal 'http://user:pass@proxy.example.com:3128'

    # Verify Faraday accepts the proxy URL during connection build.
    client = Zitadel::Client::DefaultApiClient.new(transport)
    conn = client.send(:build_connection)
    captured_proxy = conn.proxy
    _(captured_proxy).wont_be_nil
    _(captured_proxy.user).must_equal 'user'
    _(captured_proxy.password).must_equal 'pass'
  end

  # ── Bucket 3.2: no_redirect returns the 3xx as-is (does not follow) ──

  it 'returns the 308 verbatim when no_redirect: true' do
    follow_up_hit = false
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.post('/token') do
        [308, { 'location' => 'https://attacker.example.com/steal' }, '']
      end
      stub.post('/steal') do
        follow_up_hit = true
        [200, {}, '']
      end
    end
    client = Zitadel::Client::DefaultApiClient.new
    client.stub(:build_connection, stub_connection(stubs)) do
      resp = client.send_request(:POST, 'http://localhost/token', {}, 'grant_type=client_credentials', no_redirect: true)
      # The 3xx surfaces to the caller verbatim and the redirect target is
      # never hit -- the token manager inspects/rejects the 3xx itself.
      _(resp.status_code).must_equal 308
      _(resp.headers['location']).must_equal 'https://attacker.example.com/steal'
      _(follow_up_hit).must_equal false
    end
  end

  it 'returns the 307 verbatim when no_redirect: true' do
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.post('/token') do
        [307, { 'location' => 'https://attacker.example.com/steal' }, '']
      end
    end
    client = Zitadel::Client::DefaultApiClient.new
    client.stub(:build_connection, stub_connection(stubs)) do
      resp = client.send_request(:POST, 'http://localhost/token', {}, 'client_id=abc&client_secret=xyz', no_redirect: true)
      _(resp.status_code).must_equal 307
    end
  end

  it 'returns 2xx normally when no_redirect: true and no redirect' do
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.post('/token') do
        [200, { 'content-type' => 'application/json' }, '{"access_token":"ok"}']
      end
    end
    client = Zitadel::Client::DefaultApiClient.new
    client.stub(:build_connection, stub_connection(stubs)) do
      resp = client.send_request(:POST, 'http://localhost/token', {}, 'grant_type=client_credentials', no_redirect: true)
      _(resp.status_code).must_equal 200
    end
  end

  # ── Bucket 3.3: refuse body replay on HTTPS -> HTTP downgrade ──

  it 'raises ApiError when 307 redirects HTTPS -> HTTP and there is a body' do
    # 307 preserves method+body, so the original POST body would be
    # replayed over cleartext on the redirect. The downgrade guard
    # MUST refuse rather than leak the body.
    call_count = 0
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.post('/upload') do
        call_count += 1
        [307, { 'location' => 'http://insecure.example.com/upload' }, '']
      end
    end
    transport = Zitadel::Client::TransportOptions.builder.follow_redirects(true).build
    client = Zitadel::Client::DefaultApiClient.new(transport)
    client.stub(:build_connection, stub_connection(stubs)) do
      err = assert_raises(Zitadel::Client::ApiError) do
        client.send_request(:POST, 'https://localhost/upload', {}, 'secret=payload')
      end
      _(err.message).must_match(/TLS downgrade/)
    end
    _(call_count).must_equal 1
  end

  it 'allows HTTPS -> HTTP redirect when method demotes to GET with no body' do
    # 302 of a POST demotes to GET and drops the body, so there is no
    # body to replay across the downgrade — the guard MUST NOT refuse.
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.post('/r') do
        [302, { 'location' => 'http://localhost/landing' }, '']
      end
      stub.get('/landing') do
        [200, { 'content-type' => 'text/plain' }, 'ok']
      end
    end
    transport = Zitadel::Client::TransportOptions.builder.follow_redirects(true).build
    client = Zitadel::Client::DefaultApiClient.new(transport)
    client.stub(:build_connection, stub_connection(stubs)) do
      resp = client.send_request(:POST, 'https://localhost/r', {}, 'k=v')
      _(resp.status_code).must_equal 200
    end
  end

  # ── Bucket 3: redirect-exhaustion raises loudly ──

  it 'raises ApiError when the redirect budget is exhausted' do
    # The server keeps returning 302s forever. After max_redirects hops
    # the client MUST raise an ApiError rather than silently returning the
    # last 3xx response as if it were the final answer.
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/loop') do
        [302, { 'location' => 'http://localhost/loop' }, '']
      end
    end
    transport = Zitadel::Client::TransportOptions.builder
      .follow_redirects(true)
      .max_redirects(2)
      .build
    client = Zitadel::Client::DefaultApiClient.new(transport)
    client.stub(:build_connection, stub_connection(stubs)) do
      err = assert_raises(Zitadel::Client::ApiError) do
        client.send_request(:GET, 'http://localhost/loop', {}, nil)
      end
      _(err.message).must_match(/redirect/i)
    end
  end

  # ── Bucket 3: non-http(s) redirect scheme raises loudly ──

  it 'raises ApiError when Location points at a non-http(s) scheme' do
    # A Location header pointing at file:/javascript:/data: is an SSRF /
    # local-file exfiltration vector. The client MUST refuse loudly with
    # an ApiError instead of silently returning the 3xx response.
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/evil') do
        [302, { 'location' => 'file:///etc/passwd' }, '']
      end
    end
    transport = Zitadel::Client::TransportOptions.builder.follow_redirects(true).build
    client = Zitadel::Client::DefaultApiClient.new(transport)
    client.stub(:build_connection, stub_connection(stubs)) do
      err = assert_raises(Zitadel::Client::ApiError) do
        client.send_request(:GET, 'http://localhost/evil', {}, nil)
      end
      _(err.message).must_match(/non-http/i)
    end
  end

  # ── Bucket 3: use-after-close raises loudly ──

  it 'raises ApiError when send_request is called after close' do
    # After #close releases the connection pool the client is dead; a
    # subsequent send_request MUST raise an ApiError rather than lazily
    # rebuilding a connection (which would make close a silent no-op).
    client = Zitadel::Client::DefaultApiClient.new
    client.close
    err = assert_raises(Zitadel::Client::ApiError) do
      client.send_request(:GET, 'http://localhost/echo', {}, nil)
    end
    _(err.message).must_match(/closed/i)
  end

  it 'close is idempotent' do
    client = Zitadel::Client::DefaultApiClient.new
    client.close
    client.close # must not raise
  end

  # ── Bucket 3.1: API-key header names included in cross-origin strip set ──

  it 'EXTRA_SENSITIVE_HEADER_NAMES is defined and lowercase' do
    # Codegen populates this from `securitySchemes` entries with
    # type=apiKey, in=header. Whether the spec under test contains any
    # such schemes or not, the constant MUST exist and every entry
    # MUST be lowercased so the cross-origin filter compares
    # case-insensitively.
    names = Zitadel::Client::DefaultApiClient::EXTRA_SENSITIVE_HEADER_NAMES
    _(names).must_be_kind_of Array
    names.each do |n|
      _(n).must_equal n.downcase
    end
  end

  it 'always strips Authorization/Cookie/Proxy-Authorization on cross-origin redirect (Bucket 3.1)' do
    # The static credential trio (authorization, cookie,
    # proxy-authorization) is ALWAYS stripped on a cross-origin hop,
    # regardless of whether the spec declared any apiKey-in-header
    # schemes. A non-sensitive header (X-Trace) must survive the hop so
    # we know the strip is targeted, not a blanket wipe.
    captured_followup_headers = nil
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/start') do
        [302, { 'location' => 'http://otherhost.example.com/landing' }, '']
      end
      stub.get('http://otherhost.example.com/landing') do |env|
        captured_followup_headers = env.request_headers
        [200, { 'content-type' => 'text/plain' }, 'ok']
      end
    end
    transport = Zitadel::Client::TransportOptions.builder.follow_redirects(true).build
    client = Zitadel::Client::DefaultApiClient.new(transport)
    headers = {
      'Authorization' => 'Bearer secret',
      'Cookie' => 'session=abc',
      'Proxy-Authorization' => 'Basic Zm9v',
      'X-Trace' => 'keep'
    }
    client.stub(:build_connection, stub_connection(stubs)) do
      client.send_request(:GET, 'http://localhost/start', headers, nil)
    end
    _(captured_followup_headers).wont_be_nil
    lc = captured_followup_headers.transform_keys(&:downcase)
    _(lc.key?('authorization')).must_equal false
    _(lc.key?('cookie')).must_equal false
    _(lc.key?('proxy-authorization')).must_equal false
    # Non-sensitive headers must survive the cross-origin hop.
    _(lc.key?('x-trace')).must_equal true
  end

  # ── Bucket T4: explicit CA cert that cannot be read fails fast ──
  # An explicitly configured CA certificate path that cannot be read or parsed
  # must fail fast at construction with a typed ApiError rather than silently
  # falling back to the system trust store (security theater).
  it 'raises ApiError at construction for a non-existent ca_cert_path' do
    transport = Zitadel::Client::TransportOptions.builder.ca_cert_path('/nonexistent/ca.pem').build
    assert_raises(Zitadel::Client::ApiError) do
      Zitadel::Client::DefaultApiClient.new(transport)
    end
  end

  # ── decompression-error-not-wrapped ──
  # A response that advertises Content-Encoding: gzip but carries a malformed
  # (non-gzip) body must surface as the SDK's typed ApiError, not a raw
  # Zlib::GzipFile::Error leaking from inside the client. Before the fix the
  # decompress ran AFTER the rescue block, so the Zlib error escaped.
  it 'wraps a malformed Content-Encoding body as ApiError' do
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/gz') do
        [200, { 'content-type' => 'application/json', 'content-encoding' => 'gzip' }, 'not-actually-gzip']
      end
    end
    client = Zitadel::Client::DefaultApiClient.new
    client.stub(:build_connection, stub_connection(stubs)) do
      err = assert_raises(Zitadel::Client::ApiError) do
        client.send_request('GET', 'http://localhost/gz', {}, nil)
      end
      refute_kind_of Zlib::Error, err
    end
    stubs.verify_stubbed_calls
  end

  # Positive path: a correctly gzip-encoded body still decompresses normally.
  it 'decompresses a valid gzip-encoded body' do
    io = StringIO.new
    gz = Zlib::GzipWriter.new(io)
    gz.write('{"ok":true}')
    gz.close
    compressed = io.string
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/gz') do
        [200, { 'content-type' => 'application/json', 'content-encoding' => 'gzip' }, compressed]
      end
    end
    client = Zitadel::Client::DefaultApiClient.new
    client.stub(:build_connection, stub_connection(stubs)) do
      response = client.send_request('GET', 'http://localhost/gz', {}, nil)
      _(JSON.parse(response.body)['ok']).must_equal true
    end
    stubs.verify_stubbed_calls
  end

  # Positive path: a brotli-encoded body decompresses through the `br` branch
  # of decompress_body. Deterministic (no external host): the body is brotli-
  # compressed in-process via the same gem the client uses to inflate it.
  # Skipped when the optional brotli gem is absent (the alpine CI image sets
  # BUNDLE_WITHOUT=optional), since there is then nothing to compress with.
  it 'decompresses a valid brotli-encoded body' do
    skip 'brotli gem not installed (optional group)' unless defined?(Brotli)

    compressed = Brotli.deflate('{"ok":true}')
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/br') do
        [200, { 'content-type' => 'application/json', 'content-encoding' => 'br' }, compressed]
      end
    end
    client = Zitadel::Client::DefaultApiClient.new
    client.stub(:build_connection, stub_connection(stubs)) do
      response = client.send_request('GET', 'http://localhost/br', {}, nil)
      _(JSON.parse(response.body)['ok']).must_equal true
    end
    stubs.verify_stubbed_calls
  end
end
