class ApplicationController < ActionController::API
  rescue_from ServiceBinding::RoleAlreadyCreated, with: :conflict_error

  def conflict_error e
    logger.warn(e)
    head :conflict
  end
end
