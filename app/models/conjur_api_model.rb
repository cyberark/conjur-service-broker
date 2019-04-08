module ConjurApiModel
  def load_policy(policy, method: Conjur::API::POLICY_METHOD_POST)
    conjur_api.load_policy(ConjurClient.policy, policy, method: method)
  end

  def set_variable(resource_id, value)
    variable = conjur_api.resource("#{ConjurClient.account}:variable:#{resource_id}")
    variable.add_value(value)
  end

  def policy_base
    ConjurClient.policy != 'root' ? ConjurClient.policy + '/' : ''
  end

  def conjur_api
    ConjurClient.api
  end
end
