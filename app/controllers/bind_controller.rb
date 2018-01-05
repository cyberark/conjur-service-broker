class BindController < ApplicationController
  def put
    credentials = nil
    
    call_conjur_api do
      credentials = ServiceBinding.create instance_id, binding_id, app_id
    end

    render status: 201, json: {
      :credentials => {
        :account       => ConjurClient.account,
        :appliance_url => ConjurClient.appliance_url,
        :authn_login   => credentials[:authn_login],
        :authn_api_key => credentials[:authn_api_key],
      }
    }
  end

  def delete
    call_conjur_api do
      ServiceBinding.delete binding_id
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
