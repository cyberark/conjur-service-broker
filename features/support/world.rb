require 'rest_client'

module ServiceBrokerWorld
  def service_broker_host
    'http://conjur-service-broker:3000'
  end

  def last_json
    raise "No result captured!" unless @result
    JSON.pretty_generate(@result)
  end
end

World(ServiceBrokerWorld)
