class ProvisionController < ApplicationController
  def put
    render json: {}
  end

  def delete
    render status: :gone, json: {}
  end
end
