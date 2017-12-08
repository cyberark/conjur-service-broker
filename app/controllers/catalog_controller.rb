class CatalogController < ApplicationController
  def get
    render json: Rails.application.config.service_broker['catalog']
  end
end
