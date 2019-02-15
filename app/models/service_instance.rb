require 'forwardable'

class ServiceInstance
  include ConjurApiModel
  extend Forwardable

  def_delegators :resource, :exists?

  class InstanceNotFound < RuntimeError
  end

  def initialize(instance_id)
    @instance_id = instance_id
  end

  def organization_guid
    raise InstanceNotFound unless resource.exists?

    resource&.annotations['organization-guid']
  end

  def space_guid
    raise InstanceNotFound unless resource.exists?

    resource&.annotations['space-guid']
  end

  def resource
    @resource ||= conjur_api.resource(resource_id)
  end

  def resource_id
    "#{ConjurClient.account}:cf-service-instance:#{policy_base}#{@instance_id}"
  end
end
