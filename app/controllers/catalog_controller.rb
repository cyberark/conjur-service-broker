class CatalogController < ApplicationController
  def get
    render json: Rails.application.config.catalog
  end
end
