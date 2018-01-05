class UnknownConjurHostError < RuntimeError
end

class ConjurAuthenticationError < RuntimeError
end

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  rescue_from UnknownConjurHostError, with: :server_error
  rescue_from ConjurAuthenticationError, with: :invalid_configuration
  
  rescue_from ServiceBinding::HostNotFound, with: :host_not_found
  rescue_from ServiceBinding::RoleAlreadyCreated, with: :conflict_error
  
  rescue_from RestClient::Unauthorized, with: :server_error

  before_action :authenticate
  
  def authenticate
    authenticate_or_request_with_http_basic do |name, password|
      name == ENV['SECURITY_USER_NAME'] && password == ENV['SECURITY_USER_PASSWORD']
    end
  end

  def call_conjur_api
    begin
      yield
    rescue SocketError
      raise UnknownConjurHostError.new "Invalid Conjur host (#{ConjurClient.appliance_url.to_s})"
    rescue RestClient::Unauthorized => e
      raise ConjurAuthenticationError.new "Conjur authentication failed: #{e.message}"
    end
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
end
