require 'rest_client'
require 'conjur-api'
require 'conjur_client'

require 'net/http'
require 'uri'
require 'securerandom'


module ServiceBrokerWorld
  include CfHelper
  include HttpHelper
  include ConjurHelper 

  def basic_auth_username
    'TEST_USER_NAME'
  end

  def basic_auth_password
    'TEST_USER_PASSWORD'
  end

  def service_broker_host
    'http://conjur-service-broker:3000'
  end

  def store_json_response memory_id
    @response_json = JsonSpec.remember("%{#{memory_id}}")
  end

  def host_id
    parse_json(@response_json, 'credentials/authn_login').gsub(/host\//, "")
  end

  def host_annotations
    host = ConjurClient.api.resource("#{ConjurClient.account}:host:#{host_id}")
    JSON.parse(host.attributes["annotations"].to_json)
  end

  def ci_secret_user
    @test_user ||= SecureRandom.hex
  end

  def ci_secret_pass
    @test_password ||= SecureRandom.hex
  end

  def entitle_host_in_remote_conjur(host_id)
    remote_conjur do |api|
      api.load_policy('root', <<-POLICY
      - !grant
        role: !group app/secrets-users
        member: !host pcf/#{host_id}
      POLICY
      )
      end
  end  

  def service_broker_user
    @service_broker_user ||= SecureRandom.hex
  end

  def service_broker_pass
    @service_broker_pass ||= SecureRandom.hex
  end

  def integration_test_app_dir
    '/app/ci/integration/test-app'
  end

end

World(ServiceBrokerWorld)
