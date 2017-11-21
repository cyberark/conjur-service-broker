require 'rest_client'

module ServiceBrokerWorld
  def service_broker_host
    "http://localhost:3030"
  end
end

World(ServiceBrokerWorld)
