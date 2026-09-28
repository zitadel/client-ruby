# frozen_string_literal: true

D = Steep::Diagnostic

target :lib do
  check 'lib'
  signature 'sig'
  library 'base64', 'date', 'json', 'securerandom', 'time', 'cgi', 'uri', 'zlib', 'stringio', 'openssl', 'timeout'
end

# The tests are type-checked against the SDK's signatures, so a test that
# calls the SDK with the wrong argument types fails here. The minitest spec
# DSL (describe/it/_), the test-local helper classes and the stubbed methods
# have no signatures, so the diagnostics that only report their absence are
# off for this target.
target :test do
  check 'test'
  signature 'sig'
  library 'base64', 'date', 'json', 'securerandom', 'time', 'cgi', 'uri', 'zlib', 'stringio', 'openssl', 'timeout',
          'minitest', 'tempfile', 'logger'
  configure_code_diagnostics(D::Ruby.default) do |hash|
    hash[D::Ruby::NoMethod] = nil
    hash[D::Ruby::UnknownConstant] = nil
    hash[D::Ruby::UndeclaredMethodDefinition] = nil
    hash[D::Ruby::UnannotatedEmptyCollection] = nil
  end
end
