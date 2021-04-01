module ConjurApiModel
  def load_policy(policy, policy_location: ConjurConfig.policy_name)
    policy_api.load_policy(ConjurConfig.config.account, policy_location, policy)
  end

  def modify_policy(policy, policy_location: ConjurConfig.policy_name)
    policy_api.update_policy(ConjurConfig.config.account, policy_location, policy)
  end

  def set_variable(resource_id, value)
    secrets_api.create_secret(
      account=ConjurConfig.config.account, 
      kind="variable",
      identifier=resource_id,
      opts={body: value}
    )
  end

  def policy_base
    ConjurConfig.policy_name != 'root' ? ConjurConfig.policy_name + '/' : ''
  end

  def policy_api
    ConjurSDK::PoliciesApi.new ConjurConfig.client
  end

  def secrets_api
    ConjurSDK::SecretsApi.new ConjurConfig.client
  end

  def resources_api
    ConjurSDK::ResourcesApi.new ConjurConfig.client
  end

  def roles_api
    ConjurSDK::RolesApi.new ConjurConfig.client
  end

  def authn_api
    ConjurSDK::AuthenticationApi.new ConjurConfig.client
  end
end
