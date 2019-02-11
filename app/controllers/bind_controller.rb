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

  def org_guid
    params.dig(:context, :organization_guid)
  end

  def space_guid
    params.dig(:context, :space_guid)
  end

  def instance_id
    params[:instance_id]
  end

  def binding_id
    params[:binding_id]
  end

  def use_context?
    # Only create the policy for Conjur V5
    ConjurClient.v5? && org_guid.present? && space_guid.present?
  end
end
