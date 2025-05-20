# frozen_string_literal: true

require_relative 'lib/zitadel/client/version'

# noinspection RubyArgCount
Gem::Specification.new do |gemspec|
  gemspec.name = 'zitadel-client'
  gemspec.version = Zitadel::Client::VERSION
  gemspec.platform = Gem::Platform::RUBY
  gemspec.authors = ['Zitadel']
  gemspec.email = ['hi@zitadel.com']
  gemspec.homepage = 'https://zitadel.com/'
  gemspec.summary = 'Official Zitadel SDK for Ruby'
  gemspec.description =
    "Official Zitadel SDK for Ruby. Authenticate and access Zitadel's authentication and management APIs in Ruby."
  gemspec.license = 'Apache-2.0'
  gemspec.required_ruby_version = '>= 3.0'
  gemspec.metadata = { 'rubygems_mfa_required' => 'true' }

  gemspec.add_dependency 'oauth2', '~> 2.0'
  gemspec.add_dependency 'typhoeus', '~> 1.0', '>= 1.0.1'
  gemspec.add_dependency 'warning', '~> 1.5.0'
  gemspec.add_dependency 'zeitwerk', '~> 2.5'

  gemspec.files = Dir.chdir(File.expand_path(__dir__)) do
    `find lib sig README.md LICENSE -type f -print0 2>/dev/null`.split("\x0").reject do |f|
      f.match(/\.gem\z/)
    end
  end
  gemspec.executables = []
  gemspec.require_paths = ['lib']
end
