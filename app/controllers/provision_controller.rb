require 'typed_env'

class ProvisionController < ApplicationController
  def put
    Validator.validate('provision', params.to_unsafe_h)

    if use_context?
      with_conjur_exceptions do
        ServiceInstancePolicy.create(instance_id, org_guid, space_guid)
        OrgSpacePolicy.create(org_guid, space_guid)
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

    with_conjur_exceptions do
      instance = ServiceInstance.new(instance_id)

      if instance.exists?
        delete_org_space_policy(instance) unless preserve_policy?
        ServiceInstancePolicy.delete(instance_id)
      end
    end

    render json: {}
  end

  protected

  def preserve_policy?
    TypedEnv.boolean('CONJUR_PRESERVE_POLICY')
  end

  private

  def delete_org_space_policy(instance)
    OrgSpacePolicy.delete(instance.organization_guid, instance.space_guid)
  end
end
