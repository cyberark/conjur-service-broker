require 'conjur_client'

class ServiceBinding
  class RoleAlreadyCreated < RuntimeError
  end

  class << self
    def create instance_id, binding_id, app_id
      host = conjur_api.role role_name(binding_id, app_id)
      raise RoleAlreadyCreated if host.exists?

      res = conjur_api.load_policy ConjurClient.policy,
                                   template_create(binding_id)

      return {
        :authn_login => "host/#{binding_id}",
        :authn_api_key => res.created_roles.values.first['api_key']
      }
    end

    def delete binding_id
      conjur_api.load_policy ConjurClient.policy, 
                             template_delete(binding_id),
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

    def role_name binding_id, app_id
      "#{ConjurClient.account}:host:#{binding_id}"
    end

    def conjur_api
      ConjurClient.api
    end
  end
end