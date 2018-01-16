require 'conjur_client'

class ServiceBinding

  class RoleAlreadyCreated < RuntimeError
  end
  
  class HostNotFound < RuntimeError
  end

  class << self
    def create(app_guid)
      ServiceBinding.new(app_guid).create
    end

    def delete(app_guid)
      ServiceBinding.new(app_guid).delete
    end
  end
  
  def initialize(app_guid)
    @app_guid = app_guid
  end

  def create
    host = conjur_api.role(role_name)

    raise RoleAlreadyCreated.new("Host identity already exists.") if host.exists?

    result = load_policy(template_create)
    
    return {
      account: ConjurClient.account,
      appliance_url: ConjurClient.appliance_url,
      authn_login: "host/#{@app_guid}",
      authn_api_key: result.created_roles.values.first['api_key']
    }
  end

  def delete
    raise HostNotFound if @app_guid.nil?
    
    host = conjur_api.role(role_name)
    
    raise HostNotFound if !host.exists?

    host.rotate_api_key
    load_policy template_delete, method: Conjur::API::POLICY_METHOD_PATCH
  end

  private

  def template_create
    """
    - !host #{@app_guid}
    """
  end
  
  def template_delete
    """
    - !delete
      record: !host #{@app_guid}
    """
  end

  def load_policy(policy, method: Conjur::API::POLICY_METHOD_POST)
    conjur_api.load_policy(ConjurClient.policy, policy, method: method)
  end

  def role_name
    "#{ConjurClient.account}:host:#{@app_guid}"
  end

  def conjur_api
    ConjurClient.api
  end
end
