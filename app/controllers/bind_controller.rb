class MissingAppGuidError < RuntimeError
end

class BindController < ApplicationController
  def put
    raise MissingAppGuidError.new("App GUID is required") if app_id.nil?

    credentials =
      call_conjur_api do
        ServiceBinding.create(instance_id, binding_id, app_id)
      end

    render status: 201, json: { credentials: credentials }
  rescue MissingAppGuidError => e
    logger.warn(e)
    
    render status: :unprocessable_entity, json: {
      "error": "RequiresApp",
      "description": "This service supports generation of credentials through binding an application only."
    }    
  end

  def delete
    call_conjur_api do
      ServiceBinding.delete(instance_id, binding_id)
    end
    
    render json: {}
  end

  def app_id
    params[:bind_resource].try(:[], :app_guid)
  end

  def instance_id
    params[:instance_id]
  end

  def binding_id
    params[:binding_id]
  end
end
