# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require "zitadel-client/version"

Gem::Specification.new do |s|
  s.name        = "zitadel-client"
  s.version     = ZitadelClient::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Zitadel"]
  s.email       = ["hi@zitadel.com"]
  s.homepage    = "https://zitadel.com/"
  s.summary     = "Official Zitadel SDK for Ruby"
  s.description = "Official Zitadel SDK for Ruby. Authenticate and access Zitadel's authentication and management APIs in Ruby."
  s.license     = "Apache-2.0"
  s.required_ruby_version = ">= 2.7"
  s.metadata    = {}

  s.add_runtime_dependency 'typhoeus', '~> 1.0', '>= 1.0.1'

  s.add_development_dependency 'rspec', '~> 3.6', '>= 3.6.0'

  s.files         = `find *`.split("\n").uniq.sort.select { |f| !f.empty? }
  s.test_files    = `find spec/*`.split("\n")
  s.executables   = []
  s.require_paths = ["lib"]
end
