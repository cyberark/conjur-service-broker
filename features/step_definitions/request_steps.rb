Given (/^my HTTP basic auth credentials are incorrect$/) do
  @basic_auth_user = 'INCORRECT_USER_NAME'
  @basic_auth_password = 'INCORRECT_USER_PASSWORD'
end

Given (/^I use a service broker with a bad Conjur URL$/) do
  @service_broker_host = 'http://service-broker-bad-url:3001'
end

Given (/^I use a service broker with a bad Conjur API key$/) do
  @service_broker_host = 'http://service-broker-bad-key:3002'
end

Given (/^I use a service broker with a non-root policy$/) do
  @service_broker_host = 'http://service-broker-alt-policy:3003'
end

Given (/^my request doesn't include the X-Broker-API-Version header$/) do
  headers.reject! { |k, _| ['X-Broker-API-Version'].include? k }
end

When(/^I make a bind request with an existing binding_id and body:$/) do |body|
  url = "/v2/service_instances/#{SecureRandom.uuid}/service_bindings/#{SecureRandom.uuid}"

  step "I PUT \"#{url}\" with body:", body
  step "I PUT \"#{url}\" with body:", body
end

When(/^I make a bind request with body:$/) do |body|
  @service_id = SecureRandom.uuid
  @binding_id = SecureRandom.uuid
  
  url = "/v2/service_instances/#{@service_id}/service_bindings/#{@binding_id}"
  step "I PUT \"#{url}\" with body:", body
end

When(/^I make a corresponding unbind request$/) do
  url = "/v2/service_instances/#{@service_id}/service_bindings/#{@binding_id}?service_id=service-id-here&plan_id=plan-id-here"

  step "I DELETE \"#{url}\""
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

When(/^I PATCH "([^"]*)" with body:$/) do |path, body|
  try_request do
    patch_json path, body, { user: @basic_auth_user, password: @basic_auth_password, host: @service_broker_host }
  end
end

When(/^I DELETE "([^"]*)"$/) do |path|
  try_request do
    delete_json path, { user: @basic_auth_user, password: @basic_auth_password, host: @service_broker_host }
  end
end
