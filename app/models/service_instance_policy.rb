require 'conjur_client'

class ServiceInstancePolicy
  include ConjurApiModel

  class << self
    def create(instance_id, org_id, space_id)
      ServiceInstancePolicy.new(instance_id).create(org_id, space_id)
    end

    def delete(instance_id)
      ServiceInstancePolicy.new(instance_id).delete
    end
  end

  def initialize(instance_id)
    @instance_id = instance_id
  end

  def create(org_id, space_id)
    load_policy(template_create_instance(org_id, space_id))
  end

  def delete
    load_policy(template_delete_instance, 
      method: Conjur::API::POLICY_METHOD_PATCH)
  end

  private
  
  def template_create_instance(org_id, space_id)
    <<~YAML
    ---
    - !resource
      id: #{@instance_id}
      kind: cf-service-instance
      annotations:
        organization-guid: #{org_id}
        space-guid: #{space_id}
    YAML
  end

  def template_delete_instance
    <<~YAML
    ---
    - !delete
      record:
        !resource
        id: #{@instance_id}
        kind: cf-service-instance
    YAML
  end
end
