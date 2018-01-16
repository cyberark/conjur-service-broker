class MissingAppGuidError < RuntimeError
end

class BindController < ApplicationController
  @@binding_id_to_host_guid = {}
  
  def put
    raise MissingAppGuidError.new("App GUID is required") if app_guid.nil?
    
    @@binding_id_to_host_guid[binding_id] = app_guid
    
    credentials =
      with_conjur_exceptions do
        ServiceBinding.create(app_guid)
      end

    render json: { credentials: credentials }, status: :created
  rescue MissingAppGuidError => e
    logger.warn(e)
    
    render json: {
      "error": "RequiresApp",
      "description": "This service supports generation of credentials through binding an application only."
    }, status: :unprocessable_entity 
  end

  def delete
    app_guid = @@binding_id_to_host_guid[binding_id]

    with_conjur_exceptions do
      ServiceBinding.delete(app_guid)
    end
    
    render json: {}
  end

  def binding_id
    params[:binding_id]
  end
  
  def app_guid
    params[:bind_resource].try(:[], :app_guid)
  end
end
