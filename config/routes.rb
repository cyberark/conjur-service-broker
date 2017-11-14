Rails.application.routes.draw do
  get '/v2/catalog', 
    to: 'catalog#handle_request'

  put '/v2/service_instances/:instance_id', 
    to: 'provision#handle_request'

  delete '/v2/service_instances/:instance_id', 
    to: 'deprovision#handle_request'

  put '/v2/service_instances/:instance_id/service_bindings/:binding_id', 
    to: 'bind#handle_request'

  delete '/v2/service_instances/:instance_id/service_bindings/:binding_id', 
    to: 'unbind#handle_request'
end
