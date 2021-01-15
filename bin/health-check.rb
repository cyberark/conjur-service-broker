#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path('../lib', File.dirname(__FILE__))

require 'conjur_client'

def login_resource(conjur_api)
  resource_id =
    if ConjurClient.login_is_host?
      "#{ConjurClient.account}:host:#{ConjurClient.login_host_id}"
    else
      "#{ConjurClient.account}:user:#{ConjurClient.authn_login}"
    end

  conjur_api.resource(resource_id)
end

def policy_resource(conjur_api)
  policy_id = "#{ConjurClient.account}:policy:#{ConjurClient.policy}"

  conjur_api.resource(policy_id)
end

def error(message)
  raise StandardError.new(message)
end

master_api = ConjurClient.api

login_resource_exists = false

begin
  # This will throw an exception if Conjur URL is unreachable.
  login_resource = login_resource(master_api)
  
  # This will throw an exception if Conjur credentials are invalid.
  login_resource_exists = login_resource.exists?
rescue
  error(
    "Error: There is an issue with your Conjur configuration. Please verify" \
    " that the credentials are correct and try again."
  )
end

# When authenticating as a host, ensure that credentials can access host resource.
if !login_resource_exists && ConjurClient.login_is_host?
  error("Host identity not privileged to read itself.")
end

if ConjurClient.policy != 'root'
    policy_resource = policy_resource(master_api)

    # This will throw an error if the policy isn't found
    if !policy_resource.exists?
      error(
          "Error: The policy branch specified in your configuration does not exist," \
          " or is incorrect. Please verify that your policy exists and try again."
      )
    end
end

puts "Successfully validated Conjur credentials."

# If a follower URL is provided, test it using the Conjur API.
follower_url = ENV['CONJUR_FOLLOWER_URL']

if follower_url.present?
  begin
    follower_api = ConjurClient.new.api(follower_url)
    
    # This will throw an exception if the follower URL is unreachable.
    login_resource = login_resource(follower_api)
  rescue
    error(
      "Error: There is an issue with your CONJUR_FOLLOWER_URL value. Please" \
      " verify that it points to a valid Conjur installation."
    )
  end
end
