require 'conjur_client'

class ServiceBinding
  class << self
    def create instance_id, binding_id, app_id
      conjur_api.load_policy 'root', add_policy_template(binding_id)
      conjur_api.load_policy binding_id, bind_template(app_id)
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

    def conjur_api
      ConjurClient.api
    end
  end
end