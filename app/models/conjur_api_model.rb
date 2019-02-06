module ConjurApiModel

  def load_policy(policy, method: Conjur::API::POLICY_METHOD_POST)
    conjur_api.load_policy(ConjurClient.policy, policy, method: method)
  end

  def policy_base
    ConjurClient.policy != 'root' ? ConjurClient.policy + '/' : ''
  end

  def conjur_api
    ConjurClient.api
  end
end
