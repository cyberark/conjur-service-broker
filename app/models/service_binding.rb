require 'conjur_client'

class ServiceBinding

  class RoleAlreadyCreated < RuntimeError
  end
  
  class HostNotFound < RuntimeError
  end
  
  class << self
    def create instance_id, binding_id, app_id
      host = conjur_api.role role_name(binding_id, app_id)

      raise RoleAlreadyCreated if host.exists?

      result = load_policy template_create(binding_id)
      
      raise HostNotFound if !host.exists?

      return {
        :authn_login => "host/#{binding_id}",
        :authn_api_key => result.created_roles.values.first['api_key']
      }
    end

    def delete binding_id
      resource_id = "#{ConjurClient.account}:host:#{binding_id}"

      host = conjur_api.resource(resource_id)

      raise HostNotFound if !host.exists?

      load_policy template_delete(binding_id),
                  method: Conjur::API::POLICY_METHOD_PATCH
    end

    def template_delete binding_id
      """
      - !delete
        record: !host #{binding_id}
      """
    end

    def template_create binding_id
      """
      - !host #{binding_id}
      """
    end

    def load_policy policy, method: Conjur::API::POLICY_METHOD_POST
      conjur_api.load_policy ConjurClient.policy, policy, method: method
    end

    def role_name binding_id, app_id
      "#{ConjurClient.account}:host:#{binding_id}"
    end

    def conjur_api
      ConjurClient.api
    end
  end
end
