require 'conjur_client'

class UnknownConjurHostError < RuntimeError
end

class ValidationError < RuntimeError
end

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  rescue_from UnknownConjurHostError, with: :server_error
  rescue_from ConjurClient::ConjurAuthenticationError, with: :invalid_configuration

  rescue_from ServiceBinding::HostNotFound, with: :host_not_found
  rescue_from ServiceBinding::RoleAlreadyCreated, with: :conflict_error

  rescue_from ValidationError, with: :failed_validation

  rescue_from RestClient::Unauthorized, with: :server_error

  before_action :check_headers
  before_action :authenticate

  def authenticate
    authenticate_with_basic_auth || render_unauthorized
  end

  def check_headers
    if !request.headers.include?("X-Broker-API-Version")
      render json: { "description": "Your request is missing the required 'X-Broker-API-Version' header" },
      status: :precondition_failed
    end
  end

  def with_conjur_exceptions
    begin
      yield
    rescue SocketError
      raise UnknownConjurHostError.new "Invalid Conjur host (#{ConjurClient.appliance_url.to_s})"
    rescue RestClient::Unauthorized => e
      raise ConjurClient::ConjurAuthenticationError.new "Conjur authentication failed: #{e.message}"
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

  def failed_validation e
    logger.warn(e)
    render json: {
      error: "ValidationError",
      description: e
    }, status: :bad_request
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

  def use_context?
    # Only create the policy for Conjur V5
    ConjurClient.v5? && org_guid.present? && space_guid.present?
  end

  def instance_id
    params[:instance_id]
  end

  def org_guid
    params.dig(:context, :organization_guid)
  end

  def space_guid
    params.dig(:context, :space_guid)
  end
end
