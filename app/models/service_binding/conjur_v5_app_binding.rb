module ServiceBinding
  # Responsible for binding a CF application to a Conjur V5 cluster
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
      raise RoleAlreadyCreated, "Host identity already exists." if host != nil

      ServiceBinding.build_credentials(host_id, api_key)
    end

    def delete
      raise HostNotFound unless host != nil

      authn_api.rotate_api_key("authn", OpenapiConfig.account, opts={
        role: "host:#{host_id}"
      })

      modify_policy template_delete
    end

    private

    def host
      begin
        @host ||= roles_api.get_role(OpenapiConfig.account, "host", host_id)
      rescue OpenapiClient::ApiError => err
        if err.code == 401
          raise RestClient::Unauthorized
        end
        if err.code == 0
          raise RestClient::ServerBrokeConnection.new "{}"
        end
      end
    end

    def api_key
      @api_key ||= create_host
    rescue OpenapiClient::ApiError => err
      raise OpenapiConfig::ConjurAuthenticationError, "Conjur configuration invalid: #{err.message}"
    end

    def create_host
      result = load_policy(template_create)
      result[:created_roles].values.first[:api_key]
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
          #{OpenapiConfig.platform}: true
      YAML
      template if OpenapiConfig.platform.to_s.present?
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

    def load_policy(policy)
      policy_api.update_policy(OpenapiConfig.account, policy_location, policy)
    end
    
    def modify_policy(policy)
      policy_api.modify_policy(OpenapiConfig.account, policy_location, policy)
    end

    def policy_location
      use_space? ? space_policy : OpenapiConfig.policy_name
    end

    def host_id
      "#{policy_base}#{org_space}#{@binding_id}"
    end

    def org_space
      "#{@org_guid}/#{@space_guid}/" if use_space?
    end

    def role_name
      "#{OpenapiConfig.account}:host:#{host_id}"
    end

    def use_space?
      @org_guid.present? && @space_guid.present?
    end

    def space_policy
      "#{policy_base}#{@org_guid}/#{@space_guid}"
    end
  end
end
