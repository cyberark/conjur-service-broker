module ServiceBinding
  # Responsible for binding a PCF application to a Conjur V5 cluster
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
      host = api.role(role_name)

      raise HostNotFound, "No space host identity found." unless host.exists?

      ServiceBinding.build_credentials(host_id, api_key)
    end

    def delete; end

    protected

    def host_id
      "#{policy_base}#{@org_guid}/#{@space_guid}"
    end

    def role_name
      "#{ConjurClient.account}:host:#{host_id}"
    end

    def api_key
      api_key_variable = api.resource(api_key_name)

      raise ApiKeyNotFound unless api_key_variable.exists?

      api_key_variable.value
    end

    def api_key_name
      [
        ConjurClient.account,
        'variable',
        "#{policy_base}#{@org_guid}/#{@space_guid}/space-host-api-key"
      ].join(':')
    end

    # The space host binding uses the application Conjur URl so that
    # if the follower URL is configured, the bind operation will use
    # the follower, rather than the master, to perform this operation.
    def api
      @api ||= ConjurClient.new.api(ConjurClient.application_conjur_url)
    end
  end
end
