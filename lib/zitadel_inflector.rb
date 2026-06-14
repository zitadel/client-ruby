# frozen_string_literal: true

require 'zeitwerk'

# Custom Zeitwerk inflector for the generated SDK.
#
# The OpenAPI generator emits compact, acronym-aware constant names
# (+OIDCServiceApi+, +UserServiceRedirectURLs+, +IdentityProviderServiceLDAPConfig+)
# from snake_case filenames whose acronyms cannot be recovered by Zeitwerk's
# default camelization (which would produce +OidcServiceApi+ etc.). Rather than
# enumerating every acronym, this inflector reads the constant the file actually
# declares — the first +class+/+module+ whose name is not a namespace segment —
# and uses that verbatim. It falls back to the default camelization for the
# handful of files whose only declaration is a namespace segment
# (e.g. +client.rb+ -> +Client+, +zitadel.rb+ -> +Zitadel+).
class ZitadelInflector < Zeitwerk::Inflector
  # Declaration names that are namespace scaffolding rather than the file's
  # own top-level constant: the module tree the generator nests every file
  # under, plus the +Types+ helper module dry-struct models open at the top
  # of each file.
  IGNORED_DECLARATIONS = %w[Zitadel Client Api Auth Errors Models Types].freeze

  # Matches the first +class+/+module+ keyword and the constant name it declares.
  DECLARATION = /^\s*(class|module)\s+([A-Za-z0-9_]+)/

  def camelize(basename, abspath)
    return 'VERSION' if basename == 'version'

    leaf_constant(abspath) || super
  end

  private

  # The constant a file is expected to define: the first +class+ declaration
  # that is not namespace scaffolding (dry-struct models and enums), falling
  # back to the first such +module+ for the remaining hand-written/generated
  # support files.
  def leaf_constant(abspath)
    return nil unless File.file?(abspath)

    declarations = each_declaration(abspath)
    klass = declarations.find { |kind, _| kind == 'class' }
    (klass || declarations.first)&.last
  end

  # The non-scaffolding +[kind, name]+ declarations a file makes, in order.
  def each_declaration(abspath)
    File.foreach(abspath).filter_map do |line|
      kind, name = DECLARATION.match(line)&.captures
      next if name.nil? || IGNORED_DECLARATIONS.include?(name)

      [kind, name]
    end
  end
end
