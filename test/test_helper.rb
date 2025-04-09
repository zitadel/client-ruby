require 'simplecov'
require 'simplecov-lcov'

SimpleCov::Formatter::LcovFormatter.config do |config|
  config.output_directory = 'build/coverage'
  config.lcov_file_name = 'lcov.info'
  config.report_with_single_file = true
end

SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter
                         .new(
                           [
                             SimpleCov::Formatter::HTMLFormatter,
                             SimpleCov::Formatter::LcovFormatter
                           ]
                         )

SimpleCov.coverage_dir('build/coverage')
SimpleCov.start

begin
  require 'minitest/reporters'
  Minitest::Reporters.use!(
    Minitest::Reporters::SpecReporter.new(color: true)
  )
rescue LoadError
  warn 'minitest-reporters not available — install with `bundle add minitest-reporters`'
end
