class CatalogController < ApplicationController
  def get
    render json: catalog
  end

  private

  def catalog
    @CATALOG ||= generate_catalog
  end

  def generate_catalog
    catalog = Rails.application.config.service_broker['catalog']
    catalog['services'][0]['name'] = ENV['SERVICE_NAME'] || catalog['services'][0]['name']
    catalog['services'][0]['id'] = ENV['SERVICE_ID'] || catalog['services'][0]['id']
    catalog
  end
end
