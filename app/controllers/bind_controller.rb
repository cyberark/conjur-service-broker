class BindController < ApplicationController
  def put
    ServiceBinding.create instance_id, binding_id, app_id
    render '{}'
  end

  def delete
    ServiceBinding.delete instance_id, binding_id, app_id
    render '{}'
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
