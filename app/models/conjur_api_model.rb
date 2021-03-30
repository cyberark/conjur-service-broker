module ConjurApiModel
  def load_policy(policy, policy_location: OpenapiConfig.policy_name)
    policy_api.load_policy(OpenapiConfig.account, policy_location, policy)
  end

  def modify_policy(policy, policy_location: OpenapiConfig.policy_name)
    policy_api.update_policy(OpenapiConfig.account, policy_location, policy)
  end

  def set_variable(resource_id, value)
    secrets_api.create_secret(
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
    ConjurOpenApi::PoliciesApi.new OpenapiConfig.client
  end

  def secrets_api
    ConjurOpenApi::SecretsApi.new OpenapiConfig.client
  end

  def resources_api
    ConjurOpenApi::ResourcesApi.new OpenapiConfig.client
  end

  def roles_api
    ConjurOpenApi::RolesApi.new OpenapiConfig.client
  end

  def authn_api
    ConjurOpenApi::AuthenticationApi.new OpenapiConfig.client
  end
end
