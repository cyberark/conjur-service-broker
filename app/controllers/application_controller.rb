class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  rescue_from ServiceBinding::RoleAlreadyCreated, with: :conflict_error
  rescue_from RestClient::Unauthorized, with: :server_error

  http_basic_authenticate_with name: ENV['AUTH_USERNAME'], password: ENV['AUTH_PASSWORD'] unless ENV['AUTH_USERNAME'].blank? && ENV['AUTH_PASSWORD'].blank?

  def conflict_error e
    logger.warn(e)
    head :conflict
  end

  def server_error e
    logger.warn(e)
    head :internal_server_error
  end
end
