class ApplicationController < ActionController::API
  rescue_from ServiceBinding::RoleAlreadyCreated, with: :conflict_error
  rescue_from RestClient::Unauthorized, with: :server_error

  def conflict_error e
    logger.warn(e)
    head :conflict
  end

  def server_error e
    logger.warn(e)
    head :internal_server_error
  end
end
