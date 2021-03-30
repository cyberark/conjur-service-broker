#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path('../lib', File.dirname(__FILE__))

require 'conjur_client'

def login_resource(conjur_client)
  resource_api = ConjurOpenApi::ResourcesApi.new conjur_client
  resource_id =
    if OpenapiConfig.login_is_host?
      kind = "host"
      id = OpenapiConfig.login_host_id
    else
      kind = "user"
      id = OpenapiConfig.authn_login
    end

  begin
    resource_api.show_resource(OpenapiConfig.account, kind, id)
  rescue ConjurOpenApi::ApiError => err
    if err.code == 404
      nil
    else
      raise err
    end
  end
end

def policy_resource(conjur_client)
  resource_api = ConjurOpenApi::ResourcesApi.new conjur_client

  begin
    resource_api.show_resource(OpenapiConfig.account, "policy", OpenapiConfig.policy_name)
  rescue ConjurOpenApi::ApiError => err
    if err.code == 404
      nil
    else
      raise err
    end
  end
end

def error(message)
  raise StandardError.new(message)
end


login_resource_exists = false

begin
  # This will throw an exception if Conjur credentials are invalid.
  master_api = OpenapiConfig.client

  # This will throw an exception if Conjur URL is unreachable.
  login_resource = login_resource(master_api)
  
  login_resource_exists = !login_resource.nil?
rescue
  error(
    "Error: There is an issue with your Conjur configuration. Please verify" \
    " that the credentials are correct and try again."
  )
end

# When authenticating as a host, ensure that credentials can access host resource.
if !login_resource_exists && OpenapiConfig.login_is_host?
  error("Host identity not privileged to read itself.")
end

if OpenapiConfig.policy_name != 'root'
    policy_resource = policy_resource(master_api)

    # This will throw an error if the policy isn't found
    if policy_resource.nil?
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
    follower_api = OpenapiConfig.client(follower_url)
    
    # This will throw an exception if the follower URL is unreachable.
    login_resource = login_resource(follower_api)
  rescue
    error(
      "Error: There is an issue with your CONJUR_FOLLOWER_URL value. Please" \
      " verify that it points to a valid Conjur installation."
    )
  end
end
