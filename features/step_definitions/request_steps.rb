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

When(/^I make a bind request with an existing binding_id and body:$/) do |body|
  url = "/v2/service_instances/#{SecureRandom.uuid}/service_bindings/#{SecureRandom.uuid}"
  
  step "I PUT \"#{url}\" with body:", body
  step "I PUT \"#{url}\" with body:", body
end

When(/^I make a bind request with body:$/) do |body|
  url = "/v2/service_instances/#{SecureRandom.uuid}/service_bindings/#{SecureRandom.uuid}"
  step "I PUT \"#{url}\" with body:", body
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
