require 'rest_client'

module ServiceBrokerWorld
  def service_broker_host
    'http://conjur-service-broker:3000'
  end
end

World(ServiceBrokerWorld)
