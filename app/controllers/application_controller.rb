class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  rescue_from ServiceBinding::UnknownConjurHostError, with: :server_error
  rescue_from ServiceBinding::ConjurAuthenticationError, with: :invalid_configuration
  rescue_from ServiceBinding::HostNotFound, with: :host_not_found
  rescue_from ServiceBinding::RoleAlreadyCreated, with: :conflict_error
  rescue_from RestClient::Unauthorized, with: :server_error

  before_action :authenticate

  def authenticate
    authenticate_with_basic_auth || render_unauthorized
  end

  def conflict_error e
    logger.warn(e)
    render json: {}, status: :conflict
  end

  def server_error e
    logger.warn(e)
    render json: {}, status: :internal_server_error
  end

  def invalid_configuration e
    logger.warn(e)
    render json: {}, status: :forbidden
  end

  def host_not_found e
    logger.warn(e)
    render json: {}, status: :gone
  end

  private

    def authenticate_with_basic_auth
      authenticate_with_http_basic do |name, password|
        name == ENV['SECURITY_USER_NAME'] && password == ENV['SECURITY_USER_PASSWORD']
      end

    end

    def render_unauthorized
      logger.warn("HTTP Basic: Access Denied")
      render json: {}, status: :unauthorized
    end
end
