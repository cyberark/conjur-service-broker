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
    raise OrgPolicyNotFound unless org_policy.exists?
  end

  def org_policy
    ConjurClient.readonly_api.resource(org_policy_id)
  end

  def org_policy_id
    "#{ConjurClient.account}:policy:#{policy_base}#{@org_id}"
  end

  def ensure_space_policy
    raise SpacePolicyNotFound unless space_policy.exists?
  end

  def space_policy
    ConjurClient.readonly_api.resource(space_policy_id)
  end

  def space_policy_id
    "#{ConjurClient.account}:policy:#{policy_base}#{@org_id}/#{@space_id}"
  end

  def ensure_space_layer
    raise SpaceLayerNotFound unless space_layer.exists?
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
end
