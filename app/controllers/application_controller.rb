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
    username, password = ENV['AUTH_USERNAME'], ENV['AUTH_PASSWORD']
    if username.present? || password.present?
      http_basic_authenticate_with(name: username, password: password)
    end
  end
end
