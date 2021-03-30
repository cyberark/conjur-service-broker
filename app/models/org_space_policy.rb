class OrgSpacePolicy
  include ConjurApiModel

  class OrgPolicyNotFound < RuntimeError
  end

  class SpacePolicyNotFound < RuntimeError
  end

  class SpaceLayerNotFound < RuntimeError
  end

  class << self
    def ensure_exists(org_id, space_id)
      OrgSpacePolicy.new(org_id, space_id).ensure_exists
    end

    def create(org_id, space_id)
      OrgSpacePolicy.new(org_id, space_id).create
    end
  end

  def initialize(org_id, space_id)
    @org_id = org_id
    @space_id = space_id
  end

  def ensure_exists
    ensure_org_policy
    ensure_space_policy
    ensure_space_layer
  end

  def create
    load_policy(template_create_org_space)
  end

  private

  def ensure_org_policy
    raise OrgPolicyNotFound, "Unable to find #{org_policy_id} policy branch." unless org_policy != nil
  end

  def org_policy
    begin
      resources_api.show_resource(OpenapiConfig.account, "policy", "#{policy_base}#{@org_id}")
    rescue ConjurOpenApi::ApiError
      nil
    end
  end

  def org_policy_id
    "#{OpenapiConfig.account}:policy:#{policy_base}#{@org_id}"
  end

  def ensure_space_policy
    raise SpacePolicyNotFound, "Unable to find #{space_policy_id} policy branch." unless space_policy != nil
  end

  def space_policy
    begin
      resources_api.show_resource(OpenapiConfig.account, "policy", "#{policy_base}#{@org_id}/#{@space_id}")
    rescue ConjurOpenApi::ApiError
      nil
    end
  end

  def space_policy_id
    "#{OpenapiConfig.account}:policy:#{policy_base}#{@org_id}/#{@space_id}"
  end

  def ensure_space_layer
    raise SpaceLayerNotFound, "Unable to find #{space_layer_id} layer in policy." unless space_layer != nil
  end

  def space_layer
    begin
      resources_api.show_resource(OpenapiConfig.account, "layer", "#{policy_base}#{@org_id}/#{@space_id}")
    rescue ConjurOpenApi::ApiError
      nil
    end
  end

  def space_layer_id
    "#{OpenapiConfig.account}:layer:#{policy_base}#{@org_id}/#{@space_id}"
  end

  def template_create_org_space
    <<~YAML
    ---
    - !policy
      id: #{@org_id}
      body:
        - !layer

        - !policy
          id: #{@space_id}
          body:
            - !layer

        - !grant
          role: !layer
          member: !layer #{@space_id}
    YAML
  end
end
