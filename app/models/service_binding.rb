require 'conjur_client'

class ServiceBinding
  class RoleAlreadyCreated < RuntimeError
  end

  class << self
    def create instance_id, binding_id, app_id
      host = conjur_api.role role_name(binding_id, app_id)
      raise RoleAlreadyCreated if host.exists?

      conjur_api.load_policy 'root', add_policy_template(binding_id)
      res = conjur_api.load_policy binding_id, bind_template(app_id)

      return {
        :authn_login => "host/#{binding_id}/#{app_id}",
        :authn_api_key => res.created_roles.values.first['api_key']
      }
    end

    def delete instance_id, binding_id, app_id
      conjur_api.load_policy 'root', 
                             delete_policy_template(binding_id),
                             method: Conjur::API::POLICY_METHOD_PATCH
    end

    def add_policy_template binding_id
      """
      - !policy
        id: #{binding_id}
      """
    end

    def delete_policy_template binding_id
      """
      - !delete
        record: !policy #{binding_id}
      """
    end

    def bind_template app_id
      """
      - !host
        id: #{app_id}
      """
    end

    def role_name binding_id, app_id
      "#{ConjurClient.account}:host:#{binding_id}/#{app_id}"
    end

    def conjur_api
      ConjurClient.api
    end
  end
end