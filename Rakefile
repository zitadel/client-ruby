require "bundler/gem_tasks"

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = '--format documentation'
  end

  require 'rake/testtask'

  Rake::TestTask.new(:minitest) do |t|
    t.libs << "test"
    t.pattern = "test/**/*_test.rb"
  end

  task :all_tests => [:spec, :minitest]

  task default: :all_tests

rescue LoadError => e
  warn "RSpec not available: #{e}"
end
