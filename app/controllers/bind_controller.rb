class BindController < ApplicationController
  def put
    Validator.validate('bind', params.to_unsafe_h)

    credentials =
      with_conjur_exceptions do
        OrgSpacePolicy.ensure_exists(org_guid, space_guid) if use_context?
        ServiceBinding.create(instance_id, binding_id, org_guid, space_guid)
      end

    render json: { credentials: credentials }, status: :created
  end

  def delete
    Validator.validate('unbind', params.to_unsafe_h)

    with_conjur_exceptions do
      ServiceBinding.delete(instance_id, binding_id, org_guid, space_guid)
    end
    
    render json: {}
  end

  def binding_id
    params[:binding_id]
  end
end
