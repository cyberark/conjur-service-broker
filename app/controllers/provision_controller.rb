class ProvisionController < ApplicationController
  def put
    Validator.validate('provision', params.to_unsafe_h)

    if use_context?
      with_conjur_exceptions do
        OrgSpacePolicy.create(org_guid, space_guid)
        OrgSpacePolicy.ensure_exists(org_guid, space_guid)
        SpaceHostPolicy.create(org_guid, space_guid)
      end

      render json: {}, status: :created
    else
      render json: {}
    end
  end

  def patch
    Validator.validate('patch_provision', params.to_unsafe_h)

    render json: {}
  end

  def delete
    Validator.validate('deprovision', params.to_unsafe_h)

    render json: {}
  end
end
