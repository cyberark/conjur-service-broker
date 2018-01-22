class MissingAppGuidError < RuntimeError
end

class BindController < ApplicationController
  def put
    raise MissingAppGuidError.new("App GUID is required") if app_id.nil?

    Validator.validate('bind', params.to_unsafe_h)

    credentials =
        with_conjur_exceptions do
          ServiceBinding.create(instance_id, binding_id, app_id)
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
    Validator.validate('unbind', params.to_unsafe_h)

    with_conjur_exceptions do
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
