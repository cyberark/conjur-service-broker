require 'conjur_client'

class SpaceHostPolicy
  include ConjurApiModel

  class << self
    def create(org_id, space_id)
      SpaceHostPolicy.new(org_id, space_id).create
    end
  end

  def initialize(org_id, space_id)
    @org_id = org_id
    @space_id = space_id
  end

  def create
    conjur_api.load_policy(space_policy, template_create, method: Conjur::API::POLICY_METHOD_POST)
  end

  private

  def template_create
    <<~YAML.strip + "\n"
    - !host
      id: #{space_host_id}

    - !grant
      role: !layer
      member: !host #{space_host_id}

    - !variable
      id: #{space_host_api_key_variable_id}
    YAML
  end
  
  def space_host_id
    "space_host"
  end

  def space_host_api_key_variable_id
    "space_host_api_key"
  end

  def space_policy
    "#{policy_base}#{@org_id}/#{@space_id}"
  end
end
