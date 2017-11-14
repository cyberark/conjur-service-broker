class CatalogController < ApplicationController
  def handle_request
    render json: Rails.application.config.service_broker['catalog']
  end
end
