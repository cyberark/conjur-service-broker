Rails.application.routes.draw do
  get '/v2/catalog', 
    to: 'catalog#get'

  put '/v2/service_instances/:instance_id', 
    to: 'provision#put'

  patch '/v2/service_instances/:instance_id', 
    to: 'provision#patch'

  delete '/v2/service_instances/:instance_id', 
    to: 'provision#delete'

  put '/v2/service_instances/:instance_id/service_bindings/:binding_id', 
    to: 'bind#put'

  delete '/v2/service_instances/:instance_id/service_bindings/:binding_id', 
    to: 'bind#delete'
end
