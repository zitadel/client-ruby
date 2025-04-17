=begin
API Client Test

This test verifies that the ApiClient correctly builds the endpoint path using the base URL provided by
the authenticator and includes the Personal Access Token in the Authorization header.

A WireMock server is started using TestContainers and configured via a JSON mapping to simulate the
response for '/your/endpoint'. The test then invokes the API using an ApiClient that utilizes a
PersonalAccessTokenAuthenticator and asserts that the API response matches the expected output.
=end

# noinspection RubyResolve
require 'test_helper'
require 'minitest/autorun'
require "minitest/hooks/test"
require 'testcontainers'
require 'net/http'
require 'json'
require 'logger'

module ZitadelClient
  class ApiClientTest < Minitest::Test
    include Minitest::Hooks

    def before_all
      super
      @mock_server = Testcontainers::DockerContainer
                       .new("wiremock/wiremock:3.12.1")
                       .with_exposed_port(8080)
                       .start

      @mock_server.wait_for_http(container_port: 8080, path: "/", status: 403)
      # noinspection HttpUrlsUsage
      @oauth_host = "http://#{@mock_server.host}:#{@mock_server.mapped_port(8080)}"
    end

    def after_all
      @mock_server&.stop
      @mock_server&.remove
      super
    end

    ##
    # Test the ApiClient#call_api method to ensure that the correct headers and content type
    # are applied, and that a GET request to '/your/endpoint' returns the expected response.
    #
    # @return [void]
    def test_assert_headers_and_content_type
      mapping_uri = URI("#{@oauth_host}/__admin/mappings")
      http = Net::HTTP.new(mapping_uri.host || raise("Host is missing"), mapping_uri.port)
      mapping_request = Net::HTTP::Post.new(mapping_uri, { 'Content-Type' => 'application/json' })
      mapping_request.body = JSON.generate(
        {
          request: {
            method: "GET",
            url: "/your/endpoint",
            headers: {
              "Authorization" => {
                equalTo: "Bearer mm"
              },
              "User-Agent" => {
                matches: "^zitadel-client/0\\.0\\.0 \\(lang=ruby; lang_version=[^;]+; os=[^;]+; arch=[^;]+\\)$"
              }
            }
          },
          response: {
            status: 200,
            body: '{"key": "value"}',
            headers: {
              "Content-Type" => "application/json"
            }
          }
        })
      mapping_response = http.request(mapping_request)
      assert_includes [200, 201], mapping_response.code.to_i, "Mapping creation failed with status #{mapping_response.code}"

      config = Configuration.new(PersonalAccessTokenAuthenticator.new(@oauth_host, "mm"))
      api_client = ZitadelClient::ApiClient.new(config)
      data, status, headers = api_client.call_api('GET', '/your/endpoint', return_type: 'Object')
      assert_equal 200, status, "Expected status 200, but got #{status}"
      assert_instance_of(Hash, data, "Expected response data to be a Hash")
      assert_equal "application/json", headers['Content-Type'], "Expected Content-Type header to be 'application/json'"
      expected = { "key" => "value" }
      response_data = data.transform_keys(&:to_s)
      assert_equal expected, response_data, "Expected response body #{expected}, but got #{data}"
    end
  end
end
