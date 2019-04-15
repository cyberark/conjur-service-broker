module ServiceBinding
  # Responsible for binding a PCF application to a Conjur V5 cluster
  # using an app-specific host identity.
  class ConjurV5AppBinding
    include ConjurApiModel

    def initialize(instance_id, binding_id, org_guid, space_guid)
      @instance_id = instance_id
      @binding_id = binding_id
      @org_guid = org_guid
      @space_guid = space_guid
    end

    def create
      raise RoleAlreadyCreated, "Host identity already exists." if host.exists?

      ServiceBinding.build_credentials(host_id, api_key)
    end

    def delete
      raise HostNotFound unless host.exists?

      host.rotate_api_key

      load_policy template_delete, method: Conjur::API::POLICY_METHOD_PATCH
    end

    private

    def host
      @host ||= conjur_api.role(role_name)
    end

    def api_key
      @api_key ||= create_host
    rescue RestClient::NotFound => err
      raise ConjurClient::ConjurAuthenticationError, "Conjur configuration invalid: #{err.message}"
    end

    def create_host
      result = load_policy(template_create)
      result.created_roles.values.first['api_key']
    end

    def template_create
      <<~YAML.strip + "\n"
        - !host
          id: #{@binding_id}
        #{template_create_annotations}
        #{template_create_grant}
      YAML
    end

    def template_create_annotations
      template = <<~YAML.chomp.indent(2)
        annotations:
          #{ConjurClient.platform}: true
      YAML
      template if ConjurClient.platform.to_s.present?
    end

    def template_create_grant
      template = <<~YAML.chomp
        - !grant
          role: !layer
          member: !host #{@binding_id}
      YAML
      template if use_space?
    end

    def template_delete
      <<~YAML
        - !delete
          record: !host #{@binding_id}
      YAML
    end

    def load_policy(policy, method: Conjur::API::POLICY_METHOD_POST)
      conjur_api.load_policy(policy_location, policy, method: method)
    end

    def policy_location
      use_space? ? space_policy : ConjurClient.policy
    end

    def host_id
      "#{policy_base}#{org_space}#{@binding_id}"
    end

    def org_space
      "#{@org_guid}/#{@space_guid}/" if use_space?
    end

    def role_name
      "#{ConjurClient.account}:host:#{host_id}"
    end

    def use_space?
      @org_guid.present? && @space_guid.present?
    end

    def space_policy
      "#{policy_base}#{@org_guid}/#{@space_guid}"
    end
  end
end
