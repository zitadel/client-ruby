# frozen_string_literal: true

require 'dotenv'
require 'simplecov'
require 'simplecov-lcov'
require 'warning'

require_relative '../lib/zitadel_client'

Warning.ignore(:method_redefined, __dir__)
Dotenv.load('.env')

# Configure the LCOV formatter
SimpleCov::Formatter::LcovFormatter.config do |config|
  config.output_directory = 'build/coverage'
  config.lcov_file_name = 'lcov.info'
  config.report_with_single_file = true
end

# Override the HTMLFormatter so that it writes its report inside build/coverage/html
module SimpleCov
  module Formatter
    # rubocop:disable Style/Documentation
    module HTMLFormatterPatch
      def output_path
        File.join(SimpleCov.coverage_path, 'html')
      end
    end
    # rubocop:enable Style/Documentation

    class HTMLFormatter
      prepend HTMLFormatterPatch
    end
  end
end

# Set up multiple formatters: HTML and LCOV
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::LcovFormatter
  ]
)

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

  module Minitest
    module Reporters
      # rubocop:disable Metrics/AbcSize,Style/Documentation,Metrics/MethodLength
      class JUnitReporter
        private

        def parse_xml_for(xml, suite, tests)
          suite_result = analyze_suite(tests)
          file_path = get_relative_path(tests.first)

          testsuite_attributes = {
            name: suite,
            file: file_path,
            skipped: suite_result[:skip_count],
            failures: suite_result[:fail_count],
            errors: suite_result[:error_count],
            tests: suite_result[:test_count],
            assertions: suite_result[:assertion_count],
            time: suite_result[:time]
          }
          testsuite_attributes[:timestamp] = suite_result[:timestamp] if @timestamp_report

          xml.testsuite(testsuite_attributes) do
            tests.each do |test|
              line = get_source_location(test).last
              xml.testcase(
                name: test.name,
                line: line,
                classname: suite,
                assertions: test.assertions,
                time: test.time,
                file: file_path
              ) do
                xml << xml_message_for(test) unless test.passed?
                xml << xml_attachment_for(test) if test.respond_to?('metadata') && test.metadata[:failure_screenshot_path]
              end
            end
          end
        end
      end
      # rubocop:enable Metrics/AbcSize,Style/Documentation,Metrics/MethodLength
    end
  end

  unless ENV['RM_INFO']
    Minitest::Reporters.use! [
      Minitest::Reporters::SpecReporter.new(color: true),
      Minitest::Reporters::JUnitReporter.new(
        'build/reports/',
        single_file: true
      )
    ]
  end
rescue LoadError
  warn 'minitest-reporters not available — install with `bundle add minitest-reporters`'
end
