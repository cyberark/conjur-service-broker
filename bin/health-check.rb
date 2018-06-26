#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path('../lib', File.dirname(__FILE__))

require 'conjur_client'

conjur_api = ConjurClient.api

begin
  resource_id =
    if !ConjurClient.login_host_id.nil?
      "#{ConjurClient.account}:host:#{ConjurClient.login_host_id}"
    else
      "#{ConjurClient.account}:user:#{ConjurClient.authn_login}"
    end

  # This will throw an exception if the creds are invalid
  resource_exists = conjur_api.resource(resource_id).exists?
  unless resource_exists || ConjurClient.login_host_id.nil?
    raise StandardError.new("Host identity not privileged to read itself")
  end

  puts "Successfully validated Conjur credentials."
rescue
  raise "Error: There is an issue with your Conjur configuration. Please verify" \
        " that the credentials are correct and try again."
end

if ConjurClient.version == 4
  hf_id = ConjurClient.v4_host_factory_id
  
  if !conjur_api.resource(URI::encode(hf_id, "/")).exists?
    raise "Error: There is an issue with your Conjur configuration. Please" \
          " verify that your Conjur policy contains a host factory named " \
          "'#{hf_id.split(/[:\/]/)[-1]}' under the '#{ConjurClient.policy}' policy."
  end
end
