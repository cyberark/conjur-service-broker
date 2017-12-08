class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  before_filter :authenticate

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

  private

  def authenticate
    auth_username, auth_password = ENV['AUTH_USERNAME'], ENV['AUTH_PASSWORD']
    if auth_username.present? || auth_password.present?
      authenticate_or_request_with_http_basic do |username, password|
        username == auth_username && password == auth_password
      end
    end
  end
end
