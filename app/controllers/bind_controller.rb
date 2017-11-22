class BindController < ApplicationController
  def put
    credentials = ServiceBinding.create instance_id, binding_id, app_id
    render json: {
      :credentials => {
        :account       => ConjurClient.account,
        :appliance_url => ConjurClient.appliance_url,
        :authn_login   => credentials[:authn_login],
        :authn_api_key => credentials[:authn_api_key],
      }
    }
  end

  def delete
    ServiceBinding.delete binding_id
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
