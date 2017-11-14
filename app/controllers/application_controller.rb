class ApplicationController < ActionController::API
  rescue_from ServiceInstance::HostNotProvisionedError, with: :gone_error

  def gone_error e
    logger.warn(e)
    head :gone
  end
end
