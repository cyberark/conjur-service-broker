require 'conjur_client'

class OrgSpacePolicy
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

  private

  def ensure_org_policy
    raise OrgPolicyNotFound unless org_policy.exists?
  end

  def org_policy
    conjur_api.resource(org_policy_id)
  end

  def org_policy_id
    "#{ConjurClient.account}:policy:#{policy_base}#{@org_id}"
  end

  def ensure_space_policy
    raise SpacePolicyNotFound unless space_policy.exists?
  end

  def space_policy
    conjur_api.resource(space_policy_id)
  end

  def space_policy_id
    "#{ConjurClient.account}:policy:#{policy_base}#{@org_id}/#{@space_id}"
  end

  def ensure_space_layer
    raise SpaceLayerNotFound unless space_layer.exists?
  end

  def space_layer
    conjur_api.resource(space_layer_id)
  end

  def space_layer_id
    "#{ConjurClient.account}:layer:#{policy_base}#{@org_id}/#{@space_id}"
  end

  def policy_base
    ConjurClient.policy != 'root' ? ConjurClient.policy + '/' : ''
  end

  def conjur_api
    ConjurClient.api
  end
end
