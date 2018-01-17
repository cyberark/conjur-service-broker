ENV["RAILS_ENV"] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'

Dir[Rails.root.join("spec/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
end
