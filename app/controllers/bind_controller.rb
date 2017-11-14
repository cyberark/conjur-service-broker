class BindController < ApplicationController
  def put
    instance = Binding.create params[:instance_id], params[:binding_id]
    render '{}'
  end

  def delete
    instance = Binding.delete params[:instance_id], params[:binding_id]
    render '{}'
  end
end
