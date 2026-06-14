# frozen_string_literal: true
# rubocop:disable all

require 'test_helper'
require 'zitadel/client/trace_context_util'

describe Zitadel::Client::TraceContextUtil do
  parallelize_me!

  describe '.inject_trace_context' do
    it 'is a no-op without tracer' do
      headers = {}
      Zitadel::Client::TraceContextUtil.inject_trace_context(headers)
      _(headers).must_be_empty
    end

    it 'empty headers do not cause exception' do
      headers = {}
      Zitadel::Client::TraceContextUtil.inject_trace_context(headers)
      _(headers.size).must_equal(0)
    end

    it 'does not inject traceparent without OTel' do
      headers = {}
      Zitadel::Client::TraceContextUtil.inject_trace_context(headers)
      _(headers).wont_include('traceparent')
    end

    it 'does not inject tracestate without OTel' do
      headers = {}
      Zitadel::Client::TraceContextUtil.inject_trace_context(headers)
      _(headers).wont_include('tracestate')
    end

    it 'preserves Authorization header' do
      headers = { 'Authorization' => 'Bearer token123' }
      Zitadel::Client::TraceContextUtil.inject_trace_context(headers)
      _(headers['Authorization']).must_equal('Bearer token123')
    end

    it 'preserves Content-Type header' do
      headers = { 'Content-Type' => 'application/json' }
      Zitadel::Client::TraceContextUtil.inject_trace_context(headers)
      _(headers['Content-Type']).must_equal('application/json')
    end

    it 'preserves X-Request-ID header' do
      headers = { 'X-Request-ID' => 'req-12345' }
      Zitadel::Client::TraceContextUtil.inject_trace_context(headers)
      _(headers['X-Request-ID']).must_equal('req-12345')
    end

    it 'preserves all existing headers' do
      headers = {
        'Authorization' => 'Bearer token',
        'Content-Type' => 'application/json',
        'X-Request-ID' => 'abc-123'
      }
      Zitadel::Client::TraceContextUtil.inject_trace_context(headers)
      _(headers.size).must_equal(3)
      _(headers['Authorization']).must_equal('Bearer token')
      _(headers['Content-Type']).must_equal('application/json')
      _(headers['X-Request-ID']).must_equal('abc-123')
    end

    it 'injects traceparent when a span is active' do
      # .NET-specific scenario: Ruby has no ambient tracer like .NET Activity.Current;
      # active-span injection requires a fully configured OpenTelemetry SDK.
      skip('no ambient tracer; active-span injection requires a configured OpenTelemetry SDK')
    end

    it 'includes tracestate when present on the active span' do
      # .NET-specific scenario: setting tracestate on an active span requires a
      # fully configured OpenTelemetry SDK, which is out of scope for this unit test.
      skip('no ambient tracer; tracestate-present requires a configured OpenTelemetry SDK')
    end

    it 'omits tracestate when empty on the active span' do
      # .NET-specific scenario: exercising an empty tracestate on an active span
      # requires a fully configured OpenTelemetry SDK, which is out of scope here.
      skip('no ambient tracer; empty-tracestate requires a configured OpenTelemetry SDK')
    end

    it 'formats trace flags correctly on the active span' do
      # .NET-specific scenario: verifying the recorded trace-flags byte requires a
      # fully configured OpenTelemetry SDK with an active span.
      skip('no ambient tracer; trace-flags formatting requires a configured OpenTelemetry SDK')
    end
  end
end
