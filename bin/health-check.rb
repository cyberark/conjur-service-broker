#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path('../lib', File.dirname(__FILE__))

require 'conjur_client'

begin
  conjur_api = ConjurClient.api
  conjur_api.resources limit: 5
  puts "Successfully validated Conjur credentials."
rescue
  raise "Error: There is an issue with your Conjur configuration. Please verify that the credentials are correct and try again."
end
