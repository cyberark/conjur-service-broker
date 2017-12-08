Then(/^the HTTP response status code is "(\d+)"$/) do |status|
  expect(@response.code).to eq(status.to_i)
end

Then /^the result is not empty$/ do
  expect(@result).not_to be_empty
end

Then(/^there is a list of services$/) do
  expect(@result).to have_key("services")
end

Then(/^the singular service is named "([^"]*)"$/) do |expected_service|
  expect(@result['services'][0]['name'] == expected_service).to be true
end

Then(/^the singular plan is named "([^"]*)"$/) do |expected_plan|
  expect(@result['services'][0]['plans'][0]['name'] == expected_plan).to be true
end
