# Zitadel SDK SDK - AI Agent Reference

## Installation

Add to your `Gemfile`:

```ruby
gem 'zitadel-client'
```

Then run:

```bash
bundle install
```

## Quick Start

```ruby
require 'zitadel-client'

client = Zitadel::Client::Client.with_token('https://api.example.com', 'your-token')
```

## Authentication

All authentication is handled via `Authenticator` implementations passed to the client constructor.

### Bearer Token

```ruby
authenticator = Zitadel::Client::Auth::BearerAuthenticator.new('https://api.example.com', 'your-token')
client = Zitadel::Client::Client.new(authenticator)
```

## Servers

If the OpenAPI spec defines multiple servers, the generated `Zitadel::Client::Servers` module exposes each as a `ServerConfiguration` constant (e.g., `SERVER_0`, `SERVER_1`, ...) plus an `ALL` array. Pass the desired server's URL to the client:

```ruby
client = Zitadel::Client::Client.with_token(Zitadel::Client::Servers::SERVER_0.url, 'your-token')
```

## Testing

The `Authenticator` interface is the seam for tests: substitute a fake authenticator that returns a known header map, and assert your code calls the API the way you expect.

```ruby
fake_authenticator = Class.new do
  def get_auth_headers(request) = { 'Authorization' => 'Bearer test-token' }
  def host = 'https://api.example.com'
end.new

client = Zitadel::Client::Client.new(fake_authenticator)
```

## Error Handling

All API errors inherit from `ApiError`. The error hierarchy is:

- `ApiError` (base)
  - `ClientError` (4xx)
    - `BadRequestError` (400)
    - `UnauthorizedError` (401)
    - `ForbiddenError` (403)
    - `NotFoundError` (404)
    - `ConflictError` (409)
    - `UnprocessableEntityError` (422)
  - `ServerError` (5xx)
    - `InternalServerError` (500)

```ruby
begin
  result = client.pet_api.get_pet_by_id(pet_id)
rescue Zitadel::Client::Errors::NotFoundError => e
  puts "Not found: #{e.message}"
rescue Zitadel::Client::Errors::ClientError => e
  puts "Client error #{e.status_code}: #{e.message}"
rescue Zitadel::Client::Errors::ServerError => e
  puts "Server error: #{e.message}"
rescue Zitadel::Client::Errors::ApiError => e
  puts "API error: #{e.message}"
end
```

## Configuration

### Custom Transport Options

```ruby
transport = Zitadel::Client::TransportOptions.builder
  .proxy('http://proxy:3128')
  .timeout(5000)
  .build

client = Zitadel::Client::Client.new(authenticator, transport)
```

## API Methods

Each API group is exposed as a typed attribute on the client (e.g., `client.pet_api`). API classes have methods that correspond to OpenAPI operations, accepting typed request parameters and returning typed response models.

## Models

Models are generated as Ruby classes under the `Zitadel::Client::Models` namespace.

```ruby
pet = Zitadel::Client::Models::Pet.new(name: 'Fido', status: 'available')
```

## Binary / File Uploads

File upload parameters accept `File` objects or `IO`-like objects. Binary response bodies are returned as `String` with binary encoding.

## Comment Style

Use `#` comments on their own line. Never place inline comments on the same line as code.

```good
# This explains the logic
x = 1
```

```bad
x = 1  # This explains the logic
```
