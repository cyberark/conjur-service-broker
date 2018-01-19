class ProvisionController < ApplicationController
  def put
    valid, error = JSONValidator.validate('provision_put', params.to_unsafe_h)

    if valid
      render :json => {}
    else
      render :json => { :error => error }, :status => :unprocessable_entity
    end
  end

  def delete
    render json: {}, status: :gone
  end
end
