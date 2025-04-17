# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:minitest) do |t|
  t.libs << 'lib' << 'test' << 'spec'
  t.pattern = ['test/**/*_test.rb', 'spec/**/*_spec.rb']
  t.verbose = true
end

task default: :minitest
