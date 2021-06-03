require 'conjur_client'

class OrgSpacePolicy
  include ConjurApiModel

  class OrgPolicyNotFound < RuntimeError
  end

  class SpacePolicyNotFound < RuntimeError
  end

  class SpaceLayerNotFound < RuntimeError
  end

  class << self
    def ensure_exists(org_id, space_id, organization_name, space_name)
      OrgSpacePolicy.new(org_id, space_id, organization_name, space_name).ensure_exists
    end

    def create(org_id, space_id, organization_name, space_name)
      OrgSpacePolicy.new(org_id, space_id, organization_name, space_name).create
    end
  end

  def initialize(org_id, space_id, organization_name, space_name)
    @org_id = org_id
    @space_id = space_id
    @organization_name = organization_name
    @space_name = space_name
  end

  def ensure_exists
    ensure_org_policy
    ensure_space_policy
    ensure_space_layer
  end

  def create
    if @organization_name.nil?
      load_policy(template_create_org_space)
    else
      load_policy(template_create_org_space_with_annotations)
    end
  end

  private

  def ensure_org_policy
    raise OrgPolicyNotFound, "Unable to find #{org_policy} policy branch." unless org_policy.exists?
  end

  def org_policy
    ConjurClient.readonly_api.resource(org_policy_id)
  end

  def org_policy_id
    "#{ConjurClient.account}:policy:#{policy_base}#{@org_id}"
  end

  def ensure_space_policy
    raise SpacePolicyNotFound, "Unable to find #{space_policy} policy branch." unless space_policy.exists?
  end

  def space_policy
    ConjurClient.readonly_api.resource(space_policy_id)
  end

  def space_policy_id
    "#{ConjurClient.account}:policy:#{policy_base}#{@org_id}/#{@space_id}"
  end

  def ensure_space_layer
    raise SpaceLayerNotFound, "Unable to find #{space_layer} layer in policy." unless space_layer.exists?
  end

  def space_layer
    ConjurClient.readonly_api.resource(space_layer_id)
  end

  def space_layer_id
    "#{ConjurClient.account}:layer:#{policy_base}#{@org_id}/#{@space_id}"
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
  
  def template_create_org_space_with_annotations
    <<~YAML
    ---
    - !policy
      id: #{@org_id}
      annotations:
        pcf/type: org
        pcf/orgName: #{@organization_name}
      body:
        - !layer

        - !policy
          id: #{@space_id}
          annotations:
            pcf/type: space
            pcf/orgName: #{@organization_name}
            pcf/spaceName: #{@space_name}
          body:
            - !layer

        - !grant
          role: !layer
          member: !layer #{@space_id}
    YAML
  end

end
