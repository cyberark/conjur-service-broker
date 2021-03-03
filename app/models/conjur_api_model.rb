module ConjurApiModel
  def load_policy(policy, policy_location: OpenapiConfig.policy_name)
    policy_api.update_policy(OpenapiConfig.account, policy_location, policy)
  end

  def modify_policy(policy, policy_location: OpenapiConfig.policy_name)
    policy_api.modify_policy(OpenapiConfig.account, policy_location, policy)
  end

  def set_variable(resource_id, value)
    secrets_api.create_variable(
      account=OpenapiConfig.account, 
      kind="variable",
      identifier=resource_id,
      opts={body: value}
    )
  end

  def policy_base
    OpenapiConfig.policy_name != 'root' ? OpenapiConfig.policy_name + '/' : ''
  end

  def policy_api
    OpenapiClient::PoliciesApi.new OpenapiConfig.client
  end

  def secrets_api
    OpenapiClient::SecretsApi.new OpenapiConfig.client
  end

  def resources_api
    OpenapiClient::ResourcesApi.new OpenapiConfig.client
  end

  def roles_api
    OpenapiClient::RolesApi.new OpenapiConfig.client
  end

  def authn_api
    OpenapiClient::AuthnApi.new OpenapiConfig.client
  end
end
