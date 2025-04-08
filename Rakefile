# Load Bundler's gem-related tasks (e.g., for building or releasing your gem)
require "bundler/gem_tasks"

# Try loading the RSpec rake task. If RSpec is not installed, show a warning.
begin
  require 'rspec/core/rake_task'

  # Define the RSpec task with additional options if needed.
  RSpec::Core::RakeTask.new(:spec) do |t|
    # You can customize your RSpec execution options here.
    # For example, enable a more detailed output:
    t.rspec_opts = '--format documentation'
  end

  # Minitest Task
  require 'rake/testtask'

  Rake::TestTask.new(:minitest) do |t|
    t.libs << "test"
    t.pattern = "test/**/*_test.rb"  # Adjust if your file pattern is different
  end

  # Combined Task: Run both RSpec and Minitest
  task :all_tests => [:spec, :minitest]

  # Optionally, set this as the default task
  task default: :all_tests

rescue LoadError => e
  # If RSpec is not available, print a message or handle gracefully.
  warn "RSpec not available: #{e}"
end
