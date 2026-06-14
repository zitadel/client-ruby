# zitadel-client SDK

Auto-generated Ruby SDK client for the Zitadel SDK API.

## Requirements

- Ruby `>= 3.4` (the gem targets Ruby 3.4+; older runtimes are not
  supported and rubocop is configured with `TargetRubyVersion: 3.4`).
- Bundler `>= 2.x` (`gem install bundler` if missing).

## Install

```bash
bundle install
```

## Test

```bash
bundle exec rake test
```

## Lint / Format

`rubocop` is the formatter and the linter. Lint without modifying
files, then auto-correct in place:

```bash
bundle exec rubocop          # lint only
bundle exec rubocop -A       # auto-correct (format)
```

## Static analysis

`steep` type-checks the gem against the bundled RBS signatures in
`sig/`:

```bash
bundle exec steep check
```

## Gem

- Name: `zitadel-client`
- Version: `0.0.1`

## Caveats

### Decimal / `format: number` precision

Ruby's stdlib `JSON.parse` returns `Float` for JSON numbers with a
decimal point. `format: decimal` / `format: number` values are
therefore stored as `Float`, so monetary values lose exact decimal
representation. `0.1 + 0.2` in Ruby is `0.30000000000000004`.

Do not do arithmetic on prices, balances, or other money-typed
fields. If you need exact decimal arithmetic, parse the raw response
body via `JSON.parse(body, decimal_class: BigDecimal)` and use
`BigDecimal` (stdlib `bigdecimal`) for the math.

`format: int64` is unaffected — Ruby's `Integer` is arbitrary-
precision (`Bignum`) and represents the full 64-bit range without
loss.

### `format: byte` is base64-decoded into binary Strings

Properties typed `string` + `format: byte` are exposed as raw,
binary-encoded Ruby `String`s on the model surface — **not** as the
base64 text from the wire. The transport layer base64-decodes on
read and base64-encodes (strict, no line breaks) on write.

```ruby
passport = PetstoreClient::ObjectSerializer.deserialize(json, 'PetPassport')
passport.thumbnail.encoding  # => #<Encoding:ASCII-8BIT>
File.binwrite('thumb.jpg', passport.thumbnail)
```

Assigning a non-base64 string when serializing raises
`SerializationError`. Round-tripping a wire value preserves the
original bytes exactly.

### `format: uuid` is a validated String

Properties typed `string` + `format: uuid` remain Ruby `String`s
(no `uuid` gem dependency), but are validated against RFC 4122
canonical form (`/\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/`) on both
the deserialize and serialize paths. Invalid values raise
`SerializationError`. Use `SecureRandom.uuid` to generate new
identifiers.

### Discriminator no-match raises

A `oneOf` payload whose discriminator value is missing, or whose
value is not listed in the schema's `discriminator.mapping`, raises
`SerializationError` instead of silently falling through to the
base type. This matches Python / Swift / Dart / Go / Rust behaviour.

## Not supported

### Webhooks and callbacks

This SDK is **client → server** only. Spec entries describing
server-initiated calls — OAS 3.1 top-level `webhooks` and OAS 3.0
per-operation `callbacks` — are intentionally skipped during code
generation. If you need to receive webhook deliveries, write the
handler yourself and use this SDK only to deserialize the incoming
payload (e.g. by reusing the relevant request-body model).

### Conditional-required validation (`dependentRequired` / `dependentSchemas`)

JSON Schema 2019-09 keywords for "if field X is present, field Y is
also required" are **not enforced** by this SDK. No mainstream
OpenAPI client codegen implements them. The server is the authoritative
validator; if you want client-side checking, plug in a JSON Schema
validator library for your language.

### Numeric / string constraint validation

OpenAPI keywords like `minLength`, `maxLength`, `minimum`, `maximum`,
`pattern`, `minItems`, `maxItems`, `uniqueItems`, `multipleOf` are
**not enforced** by this SDK. The server is the authoritative
validator; client-side enforcement is a DX nicety, not a correctness
requirement. If you want fast-fail validation before the network
round trip, plug in a JSON Schema validator library for your language.

### SOCKS proxies

`TransportOptions.proxy()` accepts only `http://` and `https://` URLs.
Passing a `socks://`, `socks4://`, or `socks5://` scheme throws (or
panics) at construction time with a clear error. SOCKS support would
require enabling extra dependencies / feature flags on the underlying
HTTP library in every one of the 12 SDKs we generate, with non-trivial
API divergence; we explicitly chose not to. If you need SOCKS, route
through a local HTTP-CONNECT bridge or configure it at the OS level.

### Per-call cancellation

No generated operation method accepts a per-call cancellation handle.
In-flight requests can only be terminated by waiting for the configured
`TransportOptions` request timeout to fire — there is no way to abort
mid-flight from the caller side. If you need fine-grained per-call
cancellation, wrap the SDK call in your language's standard concurrency
primitives (a `Future` you cancel externally, a `Task` you orphan, an
`asyncio` task you cancel, etc.) and rely on the timeout to break the
underlying socket.

### `LICENSE` file is not auto-emitted

The package manifest declares MIT, but no `LICENSE` / `LICENSE.md` file
is generated alongside the sources. Drop the appropriate license text
into the generated tree as part of your release pipeline before
publishing to a registry — most registries warn or block on a missing
file, and the GitHub license auto-detect cannot pick up a manifest-only
declaration.
