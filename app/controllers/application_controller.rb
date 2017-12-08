class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  rescue_from ServiceBinding::RoleAlreadyCreated, with: :conflict_error
  rescue_from RestClient::Unauthorized, with: :server_error

  http_basic_authenticate_with name: ENV['SECURITY_USER_NAME'], password: ENV['SECURITY_USER_PASSWORD'] unless ENV['SECURITY_USER_NAME'].to_s.empty? && ENV['SECURITY_USER_PASSWORD'].to_s.empty?

  def conflict_error e
    logger.warn(e)
    head :conflict
  end

  def server_error e
    logger.warn(e)
    head :internal_server_error
  end
end
