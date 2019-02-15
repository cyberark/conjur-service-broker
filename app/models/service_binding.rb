require 'conjur_client'

class ServiceBinding
  include ConjurApiModel

  class RoleAlreadyCreated < RuntimeError
  end

  class HostNotFound < RuntimeError
  end

  class << self
    def create(instance_id, binding_id, org_guid, space_guid)
      ServiceBinding.new(instance_id, binding_id, org_guid, space_guid).create
    end

    def delete(instance_id, binding_id, org_guid, space_guid)
      ServiceBinding.new(instance_id, binding_id, org_guid, space_guid).delete
    end
  end

  def initialize(instance_id, binding_id, org_guid, space_guid)
    @instance_id = instance_id
    @binding_id = binding_id
    @org_guid = org_guid
    @space_guid = space_guid
  end

  def create
    host = conjur_api.role(role_name)

    raise RoleAlreadyCreated.new("Host identity already exists.") if host.exists?

    begin
      api_key = (ConjurClient.version == 4 ? create_host_v4 : create_host_v5)
    rescue RestClient::NotFound => e
      raise ConjurClient::ConjurAuthenticationError.new "Conjur configuration invalid: #{e.message}"
    end

    return {
      account: ConjurClient.account,
      appliance_url: ConjurClient.application_conjur_url,
      authn_login: "host/#{host_id}",
      authn_api_key: api_key,
      ssl_certificate: ConjurClient.ssl_cert || "",
      version: ConjurClient.version
    }
  end

  def delete
    host = conjur_api.role(role_name)

    raise HostNotFound if !host.exists?

    host.rotate_api_key

    if ConjurClient.version == 5
      load_policy template_delete, method: Conjur::API::POLICY_METHOD_PATCH
    end
  end

  private

  def create_host_v4
    hf_token =
      conjur_api.
        resource(URI::encode(ConjurClient.v4_host_factory_id, "/")).
        create_token(Time.now + 1.hour)

    options =
      if ConjurClient.platform.to_s.empty?
        {}
      else
        { annotations: { "#{ConjurClient.platform}": "true" } }
      end

    host = Conjur::API.host_factory_create_host(hf_token, host_id, options)

    host.api_key
  end

  def create_host_v5
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
    ConjurClient.v5? && @org_guid.present? && @space_guid.present?
  end

  def space_policy
    "#{policy_base}#{@org_guid}/#{@space_guid}"
  end
end
