# frozen_string_literal: true

require 'warning'
require 'dotenv'
require 'simplecov'
require 'simplecov-cobertura'
require_relative '../lib/zitadel_client'

# The SDK uses lazy Zeitwerk autoloading. The generator-owned unit tests
# exercise classes (e.g. ValueSerializer) that reference sibling constants
# (e.g. ObjectSerializer) which only resolve once Zeitwerk has loaded them.
# Eager-load every registered loader so all constants are available without
# relying on autoload trigger ordering during the tests.
Zeitwerk::Registry.loaders.each(&:eager_load)

Warning.ignore(:method_redefined, __dir__)
Dotenv.load('.env')

# Override the HTMLFormatter so that it writes its report inside build/coverage/html
module SimpleCov
  module Formatter
    module HTMLFormatterPatch
      def output_path
        File.join(SimpleCov.coverage_path, 'html')
      end
    end

    class HTMLFormatter
      prepend HTMLFormatterPatch
    end
  end
end

# Set up multiple formatters: HTML and Cobertura
# Note: formatters= already wraps in MultiFormatter, so pass a plain array
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::CoberturaFormatter
]

# Set the base coverage directory and apply filters
SimpleCov.coverage_dir('build/coverage')
SimpleCov.start do
  add_filter '/api/'
  add_filter '/models/'
  add_filter '/test/'
  add_filter '/spec/'
end

begin
  require 'minitest/reporters'

  # 🔧 Monkeypatch to override :lineno with :line
  module Minitest
    module Reporters
      class JUnitReporter
        private

        def parse_xml_for(xml, suite, tests)
          file_path = get_relative_path(tests.first)
          attributes = testsuite_attributes(suite, tests, file_path)

          # noinspection RubyResolve
          xml.testsuite(attributes) do
            tests.each { |test| emit_testcase(xml, suite, file_path, test) }
          end
        end

        def testsuite_attributes(suite, tests, file_path)
          result = analyze_suite(tests)
          timestamp = @timestamp_report ? result[:timestamp] : (result[:timestamp] || Time.now.iso8601)
          {
            name: suite, filepath: file_path,
            skipped: result[:skip_count], failures: result[:fail_count],
            errors: result[:error_count], tests: result[:test_count],
            assertions: result[:assertion_count], time: result[:time],
            timestamp: timestamp, hostname: Socket.gethostname
          }
        end

        def emit_testcase(xml, suite, file_path, test)
          xml.testcase(
            name: test.name, line: get_source_location(test).last, classname: suite,
            assertions: test.assertions, time: test.time, file: file_path
          ) do
            xml << xml_message_for(test) unless test.passed?
            xml << xml_attachment_for(test) if test.respond_to?('metadata') && test.metadata[:failure_screenshot_path]
          end
        end
      end
    end
  end

  unless ENV['RM_INFO']
    Minitest::Reporters.use! [
      Minitest::Reporters::SpecReporter.new(color: true),
      Minitest::Reporters::JUnitReporter.new('build/reports/', true, single_file: true)
    ]
  end
rescue LoadError
  warn 'minitest-reporters not available — install with `bundle add minitest-reporters`'
end

# The generator-owned spec-independent unit tests (value_serializer,
# header_selector, configuration, transport_options, trace_context_util,
# default_api_client_unit) use the minitest/spec DSL (describe/it/_()) and
# `parallelize_me!`, and rely on test_helper to load the runner. Load the spec
# DSL and autorun here so those tests run with no Docker dependency. (The
# bespoke auth tests require minitest/autorun themselves, so this is harmless
# for them.)
require 'minitest/autorun'
require 'minitest/spec'
