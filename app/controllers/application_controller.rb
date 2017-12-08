class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  rescue_from ServiceBinding::RoleAlreadyCreated, with: :conflict_error
  rescue_from RestClient::Unauthorized, with: :server_error

  http_basic_authenticate_with name: ENV['SECURITY_USER_NAME'], password: ENV['SECURITY_USER_PASSWORD'] unless ENV['SECURITY_USER_NAME'].blank? && ENV['SECURITY_USER_PASSWORD'].blank?

  def conflict_error e
    logger.warn(e)
    head :conflict
  end

  def server_error e
    logger.warn(e)
    head :internal_server_error
  end

  private

  def authenticate
    username, password = ENV['SECURITY_USER_NAME'], ENV['SECURITY_USER_PASSWORD']
    if username.present? || password.present?
      http_basic_authenticate_with(name: username, password: password)
    end
  end
end
