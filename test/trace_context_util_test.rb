# frozen_string_literal: true

require 'test_helper'
require 'logger'
require 'opentelemetry/sdk'
require 'zitadel/client/trace_context_util'

# The W3C propagator the SDK installs by default. Set explicitly, without
# OpenTelemetry::SDK.configure, so no global tracer provider is installed:
# each test drives its own provider and so controls the active span.
OpenTelemetry.logger = Logger.new(File::NULL)
OpenTelemetry.propagation = OpenTelemetry::Trace::Propagation::TraceContext.text_map_propagator

# A tracer from a real OpenTelemetry SDK provider that records every finished
# span in memory.
def sdk_tracer(sampler = OpenTelemetry::SDK::Trace::Samplers::ALWAYS_ON)
  exporter = OpenTelemetry::SDK::Trace::Export::InMemorySpanExporter.new
  provider = OpenTelemetry::SDK::Trace::TracerProvider.new(sampler: sampler)
  provider.add_span_processor(OpenTelemetry::SDK::Trace::Export::SimpleSpanProcessor.new(exporter))
  [provider.tracer('trace-context-test'), exporter]
end

# A context whose active span is a sampled remote parent carrying the given
# tracestate, which a child span inherits.
def remote_parent(tracestate)
  parent = OpenTelemetry::Trace::SpanContext.new(
    trace_id: ['0af7651916cd43dd8448eb211c80319c'].pack('H*'),
    span_id: ['b7ad6b7169203331'].pack('H*'),
    trace_flags: OpenTelemetry::Trace::TraceFlags::SAMPLED,
    tracestate: OpenTelemetry::Trace::Tracestate.from_hash(tracestate),
    remote: true
  )
  OpenTelemetry::Trace.context_with_span(OpenTelemetry::Trace.non_recording_span(parent))
end

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
      tracer, exporter = sdk_tracer
      headers = {}
      span_context = nil
      tracer.in_span('request') do |span|
        Zitadel::Client::TraceContextUtil.inject_trace_context(headers)
        span_context = span.context
      end
      flags = span_context.trace_flags.sampled? ? '01' : '00'
      _(headers['traceparent']).must_equal(
        "00-#{span_context.hex_trace_id}-#{span_context.hex_span_id}-#{flags}"
      )
      _(exporter.finished_spans.map(&:name)).must_equal(['request'])
    end

    it 'includes tracestate when present on the active span' do
      tracer, = sdk_tracer
      headers = {}
      OpenTelemetry::Context.with_current(remote_parent('vendor' => 'value')) do
        tracer.in_span('request') do
          Zitadel::Client::TraceContextUtil.inject_trace_context(headers)
        end
      end
      _(headers['tracestate']).must_equal('vendor=value')
    end

    it 'omits tracestate when empty on the active span' do
      tracer, = sdk_tracer
      headers = {}
      tracer.in_span('request') do
        Zitadel::Client::TraceContextUtil.inject_trace_context(headers)
      end
      _(headers).must_include('traceparent')
      _(headers).wont_include('tracestate')
    end

    it 'formats trace flags correctly on the active span' do
      sampled, = sdk_tracer
      unsampled, = sdk_tracer(OpenTelemetry::SDK::Trace::Samplers::ALWAYS_OFF)
      sampled_headers = {}
      unsampled_headers = {}
      sampled.in_span('sampled') { Zitadel::Client::TraceContextUtil.inject_trace_context(sampled_headers) }
      unsampled.in_span('unsampled') { Zitadel::Client::TraceContextUtil.inject_trace_context(unsampled_headers) }
      sampled_flags = sampled_headers['traceparent'].split('-')[3]
      unsampled_flags = unsampled_headers['traceparent'].split('-')[3]
      # Two lowercase hex digits; the low bit is the sampled flag.
      _(sampled_flags).must_match(/\A[0-9a-f]{2}\z/)
      _(unsampled_flags).must_match(/\A[0-9a-f]{2}\z/)
      _(sampled_flags.to_i(16) & 1).must_equal(1)
      _(unsampled_flags.to_i(16) & 1).must_equal(0)
    end
  end
end
