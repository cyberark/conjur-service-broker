require 'conjur_client'

class Binding
  class HostNotProvisionedError < RuntimeError
  end

  class << self
    # TODO: create should take the instance_id and app_id from the
    # request body and use the instance id to find this apps org 
    # & space. Name the host orgId/spaceId/appId.
    def create instance_id, binding_id
      host = conjur_api.host binding_id

      conjur_api.create_host(id: binding_id) unless host.exists?

      give_permissions host
    end

    def delete instance_id, binding_id
      host = conjur_api.host binding_id
      
      begin
        revoke_permissions conjur_api.host(binding_id)
      rescue
        raise HostNotProvisionedError
      end
    end

    def conjur_api
      ConjurClient.instance.api
    end

    def give_permissions host
      webservice = ConjurClient.instance.webservice
      webservice.permit 'authenticate', host
    end

    def revoke_permissions host
      webservice = ConjurClient.instance.webservice
      webservice.deny 'authenticate', host
    end

    def can_authenticate? host
      webservice = ConjurClient.instance.webservice
      webservice.permitted? 'authenticate', acting_as: host
    end
  end
end