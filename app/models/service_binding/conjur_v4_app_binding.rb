module ServiceBinding
  # Responsible for binding a CF application to a Conjur V4 cluster
  # using an app-specific host identity.
  class ConjurV4AppBinding
    include ConjurApiModel
    include Conjur::Escape::ClassMethods

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
      escaped_id = fully_escape(ConjurClient.v4_host_factory_id).gsub('%3A', ':')

      hf_token =
        conjur_api
        .resource(escaped_id)
        .create_token(Time.now + 1.hour)

      options =
        if ConjurClient.platform.to_s.empty?
          {}
        else
          { annotations: { "#{ConjurClient.platform}": "true" } }
        end

      host = Conjur::API.host_factory_create_host(hf_token, host_id, options)

      host.api_key
    end

    def host_id
      "#{policy_base}#{@binding_id}"
    end

    def role_name
      "#{ConjurClient.account}:host:#{host_id}"
    end
  end
end
