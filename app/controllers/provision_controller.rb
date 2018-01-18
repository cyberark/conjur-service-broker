class ProvisionController < ApplicationController
  def put
    render json: {}
  end

  def patch
    render json: {}, status: :ok
  end

  def delete
    render json: {}, status: :gone
  end
end
