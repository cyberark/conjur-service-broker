When (/^my HTTP basic auth credentials are incorrect$/) do
  @basic_auth_user = 'INCORRECT_USER_NAME'
  @basic_auth_password = 'INCORRECT_USER_PASSWORD'
end

When(/^I GET "([^"]*)"$/) do |path|
  try_request do
    get_json path, { user: @basic_auth_user, password: @basic_auth_password }
  end
end

When(/^I PUT "([^"]*)" with body:$/) do |path, body|
  try_request do
    put_json path, body, { user: @basic_auth_user, password: @basic_auth_password }
  end
end
