#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path('../lib', File.dirname(__FILE__))

require 'conjur_client'

conjur_api = ConjurClient.api

begin
  if ConjurClient.version == 5
    conjur_api.resources limit: 5
  else
    conjur_api.resource("#{ConjurClient.account}:user:admin").exists?
  end
  
  puts "Successfully validated Conjur credentials."
rescue
  raise "Error: There is an issue with your Conjur configuration. Please verify that the credentials are correct and try again."
end

if ConjurClient.version == 4
  begin
    conjur_api.resource(URI::encode(ConjurClient.v4_host_factory_id, "/")).exists?
  rescue
    raise "Error: There is an issue with your Conjur configuration. Please verify that your policy contains a host factory."
  end
end
