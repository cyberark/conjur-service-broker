require 'rest_client'
require 'conjur_client'

require 'net/http'
require 'uri'
require 'securerandom'


module ServiceBrokerWorld
  include CfHelper
  include HttpHelper

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
    host = ConjurSDK::ResourcesApi.new(ConjurConfig.client).show_resource(ConjurConfig.config.account, "host", host_id)
    host[:annotations]
  end

  def ci_secret_org
    @ci_secret_org ||= 'org-' + SecureRandom.hex
  end

  def ci_secret_space
    @ci_secret_space ||= 'space-' + SecureRandom.hex
  end

  def ci_secret_app
    @ci_secret_app ||= 'app-' + SecureRandom.hex
  end

  def privilege_in_remote_conjur(role, resource)
    policy = <<-POLICY
    - !permit
      resource: #{resource}
      privileges: [ read, execute ]
      role: #{role}
    POLICY

    remote_conjur do |api|
      api.load_policy('root', policy)
    end
  end  

  def service_broker_user
    @service_broker_user ||= SecureRandom.hex
  end

  def service_broker_pass
    @service_broker_pass ||= SecureRandom.hex
  end

  def integration_test_app_dir
    '/app/tests/integration/test-app'
  end

  def ci_user
    @ci_user ||= create_ci_user
  end

  def cf_ci_org
    @cf_ci_org ||= create_org
  end

  def cf_ci_space
    @cf_ci_space ||= create_space(cf_ci_org)
  end

  def cf_ci_service_broker_name
    @cf_ci_service_broker_name ||= 'cyberark-conjur-' + SecureRandom.hex
  end

  def org_policy_id
    "#{ENV['PCF_CONJUR_ACCOUNT']}:policy:pcf/ci/#{org_guid(cf_ci_org)}"
  end

  def space_policy_id
    ci_org_guid = org_guid(cf_ci_org)
    ci_space_guid = space_guid(cf_ci_org, cf_ci_space)
    "#{ENV['PCF_CONJUR_ACCOUNT']}:policy:pcf/ci/#{ci_org_guid}/#{ci_space_guid}"
  end

  def space_host_id
    ci_org_guid = org_guid(cf_ci_org)
    ci_space_guid = space_guid(cf_ci_org, cf_ci_space)
    "#{ENV['PCF_CONJUR_ACCOUNT']}:host:pcf/ci/#{ci_org_guid}/#{ci_space_guid}"
  end

  def space_host_api_key_variable_id
    ci_org_guid = org_guid(cf_ci_org)
    ci_space_guid = space_guid(cf_ci_org, cf_ci_space)
    "#{ENV['PCF_CONJUR_ACCOUNT']}:variable:pcf/ci/#{ci_org_guid}/#{ci_space_guid}/space-host-api-key"
  end

  def authenticate_from_json(json)
    config = ConjurSDK::Configuration.default
    config.verify_ssl = false
    creds = JSON.parse(json)["credentials"]
    config.host = creds['appliance_url']
    authn_api = ConjurSDK::AuthenticationApi.new ConjurSDK::ApiClient.new config
    authn_api.get_access_token(creds['account'], creds['authn_login'], creds['authn_api_key'], opt={accept_encoding: "base64"})
  end
end

World(ServiceBrokerWorld)
