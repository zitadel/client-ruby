# frozen_string_literal: true

require 'dotenv'
require 'simplecov'
require 'simplecov-lcov'
require_relative '../lib/zitadel_client'

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
    class HTMLFormatter
      def output_path
        File.join(SimpleCov.coverage_path, 'html')
      end
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
