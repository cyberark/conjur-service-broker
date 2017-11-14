class ProvisionController < ApplicationController
  def put
    Instance.create instance_id, org_id, space_id
    render '{}'
  end

  def delete
    render '{}'
  end
end
