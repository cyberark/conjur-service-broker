class ProvisionController < ApplicationController
  @@instance_id_to_space_guid = {}

  def put
    @@instance_id_to_space_guid[instance_id] = space_guid
    render json: {}
  end

  def delete
    render json: {}, status: :gone
  end

  def space_guid
    params[:space_guid]
  end

  def instance_id
    params[:instance_id]
  end
end
