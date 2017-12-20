When(/^I GET "([^"]*)"$/) do |path|
  try_request do
    get_json path
  end
end

When(/^I GET "([^"]*)" with incorrect basic auth credentials$/) do |path|
  try_request do
    get_json path, { user: 'INCORRECT_USER_NAME', password: 'INCORRECT_USER_PASSWORD' }
  end
end

When(/^I PUT "([^"]*)" with body:$/) do |path, body|
  try_request do
    put_json path, body
  end
end
