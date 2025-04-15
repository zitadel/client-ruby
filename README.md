# Ruby SDK for Zitadel

This is the Zitadel Ruby SDK, designed to provide a convenient and idiomatic
way to interact with the Zitadel APIs in Ruby. The SDK provides a seamless
wrapping of the Zitadel API, making it easy to authenticate service users and
perform API operations.

The SDK enables efficient integration with the Zitadel API, allowing you to
manage resources and execute actions. However, it's important to note that
this SDK is tailored for service users and is not intended for user
authentication scenarios. It does not support authentication mechanisms
like OAuth2, OIDC, or SAML for client applications, including web, mobile,
or other environments. For these types of user authentication, you should
use other libraries that are designed for the specific platform and
authentication method.

**Disclaimer**: This SDK is not suitable for implementing user authentication.
It does not handle authentication for client applications using OAuth2, OIDC,
or SAML and should not be used for scenarios requiring such functionality.
For those use cases, consider using other solutions that are designed for
user authentication across various platforms like web, mobile, or other
client environments.

## Getting Started

### Sign up for Zitadel

To use this SDK, you need a Zitadel account. Sign up at the official
Zitadel website and obtain the necessary credentials to access the API.

### Minimum Requirements

Ensure you have Ruby 3 or higher installed.

## Using the SDK

### Installation

Install the SDK by running one of the following commands:

```
gem install zitadel_client
```

If you're using Bundler use,

```
bundle add zitadel_client
```

## Authentication Methods

Your SDK offers three ways to authenticate with Zitadel. Each method has its
own benefits—choose the one that fits your situation best.

#### 1. Private Key JWT Authentication

**What is it?**
You use a JSON Web Token (JWT) that you sign with a private key stored in a
JSON file. This process creates a secure token.

**When should you use it?**

- **Best for production:** It offers strong security.
- **Advanced control:** You can adjust token settings like expiration.

**How do you use it?**

1. Save your private key in a JSON file.
2. Use the provided method to load this key and create a JWT-based
   authenticator.

**Example:**

```ruby
require 'zitadel_client'
require 'securerandom'

base_url = ENV['BASE_URL']
key_file = "/path/to/jwt-key.json"

client = ZitadelClient::Zitadel.new(
  ZitadelClient::WebTokenAuthenticator.from_json(base_url, key_file)
)

begin
  response = client.users.add_human_user(
    ZitadelClient::V2AddHumanUserRequest.new(
      username: SecureRandom.hex,
      profile: ZitadelClient::V2SetHumanProfile.new(
        given_name: 'John',
        family_name: 'Doe'
      ),
      email: ZitadelClient::V2SetHumanEmail.new(
        email: "john.doe@example.com"
      )
    )
  )
  puts "User created: #{response}"
rescue StandardError => e
  puts "Error: #{e.message}"
end
```

#### 2. Client Credentials Grant

**What is it?**
This method uses a client ID and client secret to get a secure access token,
which is then used to authenticate.

**When should you use it?**

- **Simple and straightforward:** Good for server-to-server communication.
- **Trusted environments:** Use it when both servers are owned or trusted.

**How do you use it?**

1. Provide your client ID and client secret.
2. Build the authenticator

**Example:**

```ruby
require 'zitadel_client'
require 'securerandom'

base_url     = ENV['BASE_URL']
client_id    = ENV['CLIENT_ID']
client_secret = ENV['CLIENT_SECRET']

client = ZitadelClient::Zitadel.new(
  ZitadelClient::ClientCredentialsAuthenticator.builder(
    base_url, client_id, client_secret
  ).build
)

begin
  response = client.users.add_human_user(
    ZitadelClient::V2AddHumanUserRequest.new(
      username: SecureRandom.hex,
      profile: ZitadelClient::V2SetHumanProfile.new(
        given_name: 'John',
        family_name: 'Doe'
      ),
      email: ZitadelClient::V2SetHumanEmail.new(
        email: "john.doe@example.com"
      )
    )
  )
  puts "User created: #{response}"
rescue StandardError => e
  puts "Error: #{e.message}"
end
```

#### 3. Personal Access Tokens (PATs)

**What is it?**
A Personal Access Token (PAT) is a pre-generated token that you can use to
authenticate without exchanging credentials every time.

**When should you use it?**

- **Easy to use:** Great for development or testing scenarios.
- **Quick setup:** No need for dynamic token generation.

**How do you use it?**

1. Obtain a valid personal access token from your account.
2. Create the authenticator with: `PersonalAccessTokenAuthenticator`

**Example:**

```ruby
require 'zitadel_client'
require 'securerandom'

base_url   = ENV['BASE_URL']
valid_token = ENV['AUTH_TOKEN']

client = ZitadelClient::Zitadel.new(
  ZitadelClient::PersonalAccessTokenAuthenticator.new(base_url, valid_token)
)

begin
  response = client.users.add_human_user(
    ZitadelClient::V2AddHumanUserRequest.new(
      username: SecureRandom.hex,
      profile: ZitadelClient::V2SetHumanProfile.new(
        given_name: 'John',
        family_name: 'Doe'
      ),
      email: ZitadelClient::V2SetHumanEmail.new(
        email: "john.doe@example.com"
      )
    )
  )
  puts "User created: #{response}"
rescue StandardError => e
  puts "Error: #{e.message}"
end
```

---

Choose the authentication method that best suits your needs based on your
environment and security requirements. For more details, please refer to the
[Zitadel documentation on authenticating service users](https://zitadel.com/docs/guides/integrate/service-users/authenticate-service-users).

### Debugging

The SDK supports debug logging, which can be enabled for troubleshooting
and debugging purposes. You can enable debug logging by setting the `debug`
flag to `true` when initializing the `Zitadel` client, like this:

```ruby
zitadel = zitadel.Zitadel("your-zitadel-base-url", 'your-valid-token', lambda config: config.debug = True)
```

When enabled, the SDK will log additional information, such as HTTP request
and response details, which can be useful for identifying issues in the
integration or troubleshooting unexpected behavior.

## Design and Dependencies

This SDK is designed to be lean and efficient, focusing on providing a
streamlined way to interact with the Zitadel API. It relies on the commonly used
urllib3 HTTP transport for making requests, which ensures that
the SDK integrates well with other libraries and provides flexibility
in terms of request handling and error management.

## Versioning

This SDK follows [Semantic Versioning](https://semver.org/). You can refer to
the releases for details on the changes between versions.

## Contributing

This repository is autogenerated. We do not accept direct contributions.
Instead, please open an issue for any bugs or feature requests.

## Reporting Issues

If you encounter any issues or have suggestions for improvements, please
open an issue in the [issue tracker](https://github.com/zitadel/client-ruby/issues).
When reporting an issue, please provide the following information to help
us address it more effectively:

- A detailed description of the problem or feature request
- Steps to reproduce the issue (if applicable)
- Any relevant error messages or logs
- Environment details (e.g., OS version, relevant configurations)

## Support

If you need help setting up or configuring the SDK (or anything
Zitadel), please head over to the [Zitadel Community on Discord](https://zitadel.com/chat).

There are many helpful people in our Discord community who are ready to
assist you.

Cloud and enterprise customers can additionally reach us privately via our
[support communication channels](https://zitadel.com/docs/legal/service-description/support-services).

## License

This SDK is distributed under the Apache 2.0 License.
