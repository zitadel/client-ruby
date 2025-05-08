# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rdoc/task'

Rake::RDocTask.new(:rdoc) do |task|
  task.title = 'My Ruby Project Documentation'
  task.rdoc_dir = 'build/docs'
  task.main = 'README.md'
  task.rdoc_files.include('README.md')
  task.rdoc_files.include('lib/**/*.rb')
end

Rake::TestTask.new(:minitest) do |task|
  task.libs << 'lib' << 'test' << 'spec'
  task.pattern = %w[test/**/*_test.rb spec/**/*_spec.rb]
  task.verbose = true
end

task default: :minitest
