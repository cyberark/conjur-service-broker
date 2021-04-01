module ServiceBinding
  # Responsible for binding a CF application to a Conjur V5 cluster
  # using a space-wide host identity.
  class ConjurV5SpaceBinding
    include ConjurApiModel

    class ApiKeyNotFound < RuntimeError
    end

    def initialize(instance_id, binding_id, org_guid, space_guid)
      @instance_id = instance_id
      @binding_id = binding_id
      @org_guid = org_guid
      @space_guid = space_guid
    end

    def create
      begin
        host = roles_api.show_role(ConjurConfig.config.account, "host", host_id)
      rescue ConjurSDK::ApiError
        host = nil
      end

      raise HostNotFound, "No space host identity found." unless host != nil

      ServiceBinding.build_credentials(host_id, api_key)
    end

    def delete; end

    protected

    def host_id
      "#{policy_base}#{@org_guid}/#{@space_guid}"
    end

    def role_name
      "#{ConjurConfig.config.account}:host:#{host_id}"
    end

    def api_key
      begin
        api_key_variable = resources_api.show_resource(ConjurConfig.config.account, "variable", "#{policy_base}#{@org_guid}/#{@space_guid}/space-host-api-key")
      rescue ConjurSDK::ApiError
        api_key_variable = nil
      end
      raise ApiKeyNotFound unless api_key_variable != nil

      api_key_variable[:value]
    end

    def api_key_name
      [
        ConjurConfig.config.account,
        'variable',
        "#{policy_base}#{@org_guid}/#{@space_guid}/space-host-api-key"
      ].join(':')
    end
  end
end
