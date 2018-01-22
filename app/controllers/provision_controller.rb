class ProvisionController < ApplicationController
  def put
    Validator.validate('provision', params.to_unsafe_h)

    render :json => {}
  end

  def patch
    render json: {}, status: :ok
  end

  def delete
    Validator.validate('deprovision', params.to_unsafe_h)

    render json: {}, status: :gone
  end
end
