class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  rescue_from ServiceBinding::UnknownConjurHostError, with: :server_error
  rescue_from ServiceBinding::ConjurAuthenticationError, with: :invalid_configuration
  rescue_from ServiceBinding::RoleAlreadyCreated, with: :conflict_error
  rescue_from RestClient::Unauthorized, with: :server_error

  before_action :authenticate

  def authenticate
    authenticate_or_request_with_http_basic do |name, password|
      name == ENV['SECURITY_USER_NAME'] && password == ENV['SECURITY_USER_PASSWORD']
    end
  end

  def conflict_error e
    logger.warn(e)
    head :conflict
  end

  def server_error e
    logger.warn(e)
    head :internal_server_error
  end

  def invalid_configuration e
    logger.warn(e)
    head :forbidden
  end
end
