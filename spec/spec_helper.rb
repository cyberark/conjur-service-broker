require File.expand_path('../../config/environment', __FILE__)

require 'rspec/rails'

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.syntax = [:should, :expect]
  end
  config.expect_with :rspec do |expectations|
    expectations.syntax = [:should, :expect]
  end
end
