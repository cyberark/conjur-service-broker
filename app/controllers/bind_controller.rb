class BindController < ApplicationController
  def put
    credentials =
      call_conjur_api do
        ServiceBinding.create(instance_id, binding_id, app_id)
      end

    render status: 201, json: { credentials: credentials }
  end

  def delete
    call_conjur_api do
      ServiceBinding.delete(instance_id, binding_id)
    end
    
    render json: {}
  end

  def app_id
    params[:bind_resource][:app_guid]
  end

  def instance_id
    params[:instance_id]
  end

  def binding_id
    params[:binding_id]
  end
end
