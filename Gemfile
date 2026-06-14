# frozen_string_literal: true

source 'https://rubygems.org'

ruby '>= 3.4'

# Pull in the gem's runtime dependencies (dry-struct, faraday, jwt, zeitwerk,
# warning, ...) from the gemspec so the library and its hand-written
# Zeitwerk entrypoint load without duplicating the dependency list here.
gemspec

# Pinned to the version bundled with the Ruby base image so bundler resolves
# it to the precompiled default gem instead of compiling a newer one from
# source — bigdecimal is a C extension with no musl build and would otherwise
# fail on the toolchain-free Alpine base.
gem 'bigdecimal', '3.1.8'

gem 'dry-struct', '~> 1.6'
gem 'dry-types', '~> 1.7'
gem 'faraday', '~> 2.0'
gem 'faraday-follow_redirects', '~> 0.3'
gem 'iso8601', '~> 0.13'
gem 'tod', '~> 3.1'

group :development, :test do
  gem 'better_coverage', '~> 1.1'
  gem 'docker-api', '~> 2.2'
  gem 'dotenv', '~> 3.1'
  gem 'minitest', '~> 5.0'
  gem 'minitest-hooks', '~> 1.5'
  gem 'minitest-reporters', '~> 1.8'
  gem 'rake', '~> 13.4'
  gem 'rubocop', '~> 1.87', require: false
  gem 'rubocop-minitest', '~> 0.39', require: false
  gem 'rubocop-rake', '~> 0.7', require: false
  gem 'simplecov', '~> 0.22', require: false
  gem 'simplecov-cobertura', '~> 3.1', require: false
  gem 'steep', '~> 2.0', require: false
  gem 'testcontainers', '~> 0.2'
  gem 'yard', '~> 0.9', require: false
end

# Optional response-decompression backends. Both are C-extension gems with no
# precompiled musl build and do not compile cleanly on Alpine even with a
# toolchain, so they are excluded from the default install (the test image
# sets BUNDLE_WITHOUT=optional). The client requires them under begin/rescue
# and only advertises br/zstd in Accept-Encoding when the constant is defined,
# so omitting them is safe; consumers opt in on a glibc platform.
group :optional do
  gem 'brotli', '~> 0.5'
  gem 'zstd-ruby', '~> 1.5'
end
