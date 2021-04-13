# Create a Conjur Host identity corresponding to the specified Cloud Foundry
# space and store its API key in a Conjur Variable.
class SpaceHostPolicy
  include ConjurApiModel

  class << self
    def create(org_id, space_id)
      SpaceHostPolicy.new(org_id, space_id).create
    end

    def enabled?
      ENV['ENABLE_SPACE_IDENTITY'] == 'true'
    end
  end

  def initialize(org_id, space_id)
    @org_id = org_id
    @space_id = space_id
  end

  def create
    result = modify_policy(template_create, policy_location: space_policy)

    created_role = result[:created_roles].values.first

    return if created_role.nil?

    variable_id = "#{space_policy}/#{space_host_api_key_variable_id}"
    set_variable(variable_id, created_role[:api_key])
  end

  private

  def template_create
    <<~YAML.strip + "\n"
      - !host

      - !grant
        role: !layer
        member: !host

      - !variable
        id: #{space_host_api_key_variable_id}

      - !permit
        role: !host /#{ConjurConfig.login_host_id}
        privileges: [read]
        resource: !variable #{space_host_api_key_variable_id}
    YAML
  end

  def space_host_api_key_variable_id
    "space-host-api-key"
  end

  def space_policy
    "#{policy_base}#{@org_id}/#{@space_id}"
  end
end
