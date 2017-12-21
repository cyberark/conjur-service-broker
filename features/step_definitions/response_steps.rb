Then(/^the HTTP response status code is "(\d+)"$/) do |status|
  expect(@response.code).to eq(status.to_i)
end

Then /^the result is not empty$/ do
  expect(@response_body).not_to be_empty
end

Then(/^there is a list of services$/) do
  expect(@response_body).to have_key("services")
end

Then(/^the singular service is named "([^"]*)"$/) do |expected_service|
  expect(@response_body['services'][0]['name']).to eq expected_service
end

Then(/^the singular plan is named "([^"]*)"$/) do |expected_plan|
  expect(@response_body['services'][0]['plans'][0]['name']).to eq expected_plan
end
