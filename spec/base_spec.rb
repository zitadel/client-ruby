# frozen_string_literal: true

require 'minitest/autorun'
require 'logger'
require 'tempfile'
require 'minitest/hooks/test'

LOGGER = Logger.new($stdout)
LOGGER.level = Logger::INFO

# Abstract base class for integration tests that interact with a Docker
# Compose stack.
#
# This class handles the lifecycle of the Docker Compose environment,
# bringing it up before tests run and tearing it down afterward. It also
# provides mechanisms to load specific data (like authentication tokens
# and JWT keys) from environment variables and makes them accessible via
# instance variables for use in concrete test implementations.
class BaseSpec < Minitest::Spec
  # noinspection RbsMissingTypeSignature
  include Minitest::Hooks

  # Set up the Docker Compose environment
  #
  # This method brings up the Docker Compose stack before each test run,
  # waits for the services to initialize, and loads necessary data such as
  # authentication tokens and JWT keys into instance variables.
  # rubocop:disable Metrics/MethodLength
  def setup_docker_compose
    @compose_file_path = File.join(File.dirname(__FILE__), '..', 'etc', 'docker-compose.yaml')
    raise 'docker-compose file not found!' unless File.exist?(@compose_file_path)

    command = [
      'docker', 'compose', '--file', @compose_file_path,
      'up', '--detach', '--no-color', '--quiet-pull', '--yes'
    ]
    result = `#{command.join(' ')}`
    raise "Failed to bring up Docker Compose stack. Error: #{result}" unless $CHILD_STATUS.success?

    LOGGER.info('Docker Compose stack is up.')
    sleep 20

    @base_url = 'http://localhost:8099'
    @auth_token = load_file_content_into_property('zitadel_output/pat.txt', 'auth_token')

    jwt_key_path = File.join(File.dirname(__FILE__), '..', 'etc', 'zitadel_output', 'sa-key.json')
    raise 'JWT Key file not found!' unless File.exist?(jwt_key_path)

    @jwt_key = jwt_key_path
    LOGGER.info("Loaded JWT_KEY path: #{@jwt_key}")
  end
  # rubocop:enable Metrics/MethodLength

  # Tear down the Docker Compose environment
  #
  # This method stops the Docker Compose stack and removes any associated
  # volumes after the tests are finished.
  def teardown_docker_compose
    command = [
      'docker', 'compose', '--file', @compose_file_path,
      'down', '-v'
    ]
    result = `#{command.join(' ')}`
    raise "Failed to tear down Docker Compose stack. Error: #{result}" unless $CHILD_STATUS.success?

    LOGGER.info('Docker Compose stack torn down.')
  end

  # Setup before each test
  #
  # This callback runs before each test in the class. It will start the
  # Docker Compose environment and load necessary configuration.
  def before_all
    setup_docker_compose
  end

  # Teardown after each test
  #
  # This callback runs after each test in the class. It will stop and
  # clean up the Docker Compose environment to ensure a clean state for
  # the next test.
  def after_all
    teardown_docker_compose
  end

  def load_file_content_into_property(relative_path, property_name)
    file_path = File.join(File.dirname(__FILE__), '..', 'etc', relative_path)

    raise "File not found for property '#{property_name}': #{file_path}" unless File.exist?(file_path)

    content = File.read(file_path).strip
    LOGGER.info("Loaded #{file_path} content into property: #{property_name}")
    content
  end
end
