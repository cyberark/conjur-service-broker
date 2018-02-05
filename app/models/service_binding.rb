require 'conjur_client'

class ServiceBinding

  class RoleAlreadyCreated < RuntimeError
  end
  
  class HostNotFound < RuntimeError
  end

  class << self
    def create(instance_id, binding_id, app_id)
      ServiceBinding.new(instance_id, binding_id).create(app_id)
    end

    def delete(instance_id, binding_id)
      ServiceBinding.new(instance_id, binding_id).delete
    end
  end
  
  def initialize(instance_id, binding_id)
    @instance_id = instance_id
    @binding_id = binding_id
  end

  def create(app_id)
    host = conjur_api.role(role_name)

    raise RoleAlreadyCreated.new("Host identity already exists.") if host.exists?

    result = load_policy(template_create)
    host =
      if ConjurClient.policy != 'root'
        "host/#{ConjurClient.policy}/#{@binding_id}"
      else
        "host/#{@binding_id}"
      end
    
    return {
      account: ConjurClient.account,
      appliance_url: ConjurClient.appliance_url,
      authn_login: host,
      authn_api_key: result.created_roles.values.first['api_key'],
      version: ConjurClient.version
    }
  end

  def delete
    host = conjur_api.role(role_name)
    raise HostNotFound if !host.exists?

    host.rotate_api_key
    load_policy template_delete, method: Conjur::API::POLICY_METHOD_PATCH
  end

  private

  def template_create
    """
    - !host #{@binding_id}
    """
  end
  
  def template_delete
    """
    - !delete
      record: !host #{@binding_id}
    """
  end

  def load_policy(policy, method: Conjur::API::POLICY_METHOD_POST)
    conjur_api.load_policy(ConjurClient.policy, policy, method: method)
  end

  def role_name
    "#{ConjurClient.account}:host:#{@binding_id}"
  end

  def conjur_api
    ConjurClient.api
  end
end
