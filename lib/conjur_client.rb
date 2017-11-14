require 'singleton'

class ConjurClient
  include Singleton

  def webservice_name
    "webservice:service-broker"
  end

  def service_host_name
    "conjur/service-broker"
  end

  def service_host
    api.host service_host_name
  end

  def webservice
    api.resource webservice_name
  end

  def api
    @api_client ||= Conjur::API.new_from_token token
  end

  def token
    @token ||= 
      Conjur::API.authenticate_local "host/#{service_host_name}"
  end
end