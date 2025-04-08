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

  task test: :spec

  # Set the default rake task to run the spec suite.
  task default: :spec

rescue LoadError => e
  # If RSpec is not available, print a message or handle gracefully.
  warn "RSpec not available: #{e}"
end
