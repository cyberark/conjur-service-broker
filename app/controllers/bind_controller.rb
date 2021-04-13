class BindController < ApplicationController
  def put
    Validator.validate('bind', params.to_unsafe_h)

    credentials =
      with_conjur_exceptions do
        OrgSpacePolicy.ensure_exists(org_guid, space_guid) if use_context?
        service_binding.create
      end

    render json: { credentials: credentials }, status: :created
  end

  def delete
    Validator.validate('unbind', params.to_unsafe_h)

    with_conjur_exceptions do
      service_binding.delete
    end
    
    render json: {}
  end

  protected

  def service_binding
    @service_binding ||= ServiceBinding.from_hash(
      conjur_version: ConjurSDK.version,
      enable_space_identity: SpaceHostPolicy.enabled?
    ).new(instance_id, binding_id, org_guid, space_guid)
  end

  def binding_id
    params[:binding_id]
  end
end
