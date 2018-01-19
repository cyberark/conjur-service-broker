class BindController < ApplicationController
  def put
    Validator.validate('bind', params.to_unsafe_h)

    credentials =
      with_conjur_exceptions do
        ServiceBinding.create(instance_id, binding_id, app_id)
      end

    render json: { credentials: credentials }, status: :created
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
