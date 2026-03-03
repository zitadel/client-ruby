# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'steep/rake_task'
require 'rubocop/rake_task'

RuboCop::RakeTask.new(:rubocop) do |task|
  task.plugins << 'rubocop-minitest'
  task.plugins << 'rubocop-rake'
  task.verbose = true
end

Steep::RakeTask.new(:steep) do |task|
  task.check.severity_level = :error
  task.watch.verbose
end

begin
  require 'rdoc/task'

  Rake::RDocTask.new(:rdoc) do |task|
    task.title = 'Zitadel'
    task.rdoc_dir = 'build/docs'
    task.main = 'README.md'
    task.rdoc_files.include('README.md')
    task.rdoc_files.include('lib/**/*.rb')
  end
rescue LoadError
  # rdoc is not a default gem in Ruby 4.0+
end

Rake::TestTask.new(:test) do |task|
  task.libs << 'lib' << 'test' << 'spec'
  task.pattern = %w[test/**/*_test.rb spec/**/*_spec.rb]
  task.verbose = false
end

task default: :test
