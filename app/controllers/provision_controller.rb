class ProvisionController < ApplicationController
  def put
    render json: {}
  end

  def delete
    render json: {}, status: :gone
  end
end
