When (/^my HTTP basic auth credentials are incorrect$/) do
  @basic_auth_user = 'INCORRECT_USER_NAME'
  @basic_auth_password = 'INCORRECT_USER_PASSWORD'
end

When (/^I use a service broker with a bad Conjur URL$/) do
  @service_broker_host = 'http://service-broker-bad-url:3001'
end

When (/^I use a service broker with a bad Conjur API key$/) do
  @service_broker_host = 'http://service-broker-bad-key:3002'
end

When (/^my request doesn't include the X-Broker-API-Version header$/) do
  headers.reject! { |k, _| ['X-Broker-API-Version'].include? k }
end

When(/^I make a bind request with app_guid "([^"]*)"$/) do |app_guid|
  url = "/v2/service_instances/#{SecureRandom.uuid}/service_bindings/#{SecureRandom.uuid}"

  @last_bind_url = url
  
  body =
    {
      "service_id": "cfa8d6c0-105d-45e7-8510-2811bc57a186",
      "plan_id": "52201f0a-b370-493a-ac2b-e4eabf6b050f",
      "bind_resource": {
        "app_guid": app_guid
      },
      "parameters": {
        "parameter1": 1,
        "parameter2": "foo"
      }
    }
  
  step "I PUT \"#{url}\" with body:", body.to_json
end

When(/^I make a bind request$/) do
  step "I make a bind request with app_guid \"#{SecureRandom.uuid}\""
end

When(/^I make a bind request with body:$/) do |body|
  url = "/v2/service_instances/#{SecureRandom.uuid}/service_bindings/#{SecureRandom.uuid}"
  step "I PUT \"#{url}\" with body:", body
end

When(/^I make a bind request with an existing app_guid$/) do
  app_guid = SecureRandom.uuid
  
  step "I make a bind request with app_guid \"#{app_guid}\""
  step "I make a bind request with app_guid \"#{app_guid}\""
end

When(/^I bind and then unbind$/) do
  url = "/v2/service_instances/#{SecureRandom.uuid}/service_bindings/#{SecureRandom.uuid}"

  body =
    {
      "service_id": "cfa8d6c0-105d-45e7-8510-2811bc57a186",
      "plan_id": "52201f0a-b370-493a-ac2b-e4eabf6b050f",
      "bind_resource": {
        "app_guid": SecureRandom.uuid
      },
      "parameters": {
        "parameter1": 1,
        "parameter2": "foo"
      }
    }.to_json
  
  step "I PUT \"#{url}\" with body:", body
  step "I DELETE \"#{url}\""
end

When(/^I make an unbind request to the same endpoint$/) do
  step "I DELETE \"#{@last_bind_url}\""
end

When(/^I GET "([^"]*)"$/) do |path|
  try_request do
    get_json path, { user: @basic_auth_user, password: @basic_auth_password, host: @service_broker_host }
  end
end

When(/^I PUT "([^"]*)" with body:$/) do |path, body|
  try_request do
    put_json path, body, { user: @basic_auth_user, password: @basic_auth_password, host: @service_broker_host }
  end
end

When(/^I DELETE "([^"]*)"$/) do |path|
  try_request do
    delete_json path, { user: @basic_auth_user, password: @basic_auth_password, host: @service_broker_host }
  end
end
