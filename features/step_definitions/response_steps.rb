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

And(/^the JSON from "([^"]*)" has (in)?valid conjur credentials$/) do |memory_id, negate|
  response_json = JsonSpec.remember("%{#{memory_id}}")

  if negate
    expect{ conjur_authenticate_from_json(response_json) }.to raise_error(RestClient::Unauthorized)
  else
    expect{ conjur_authenticate_from_json(response_json) }.not_to raise_error
  end
end

And(/^the JSON has valid conjur credentials$/) do
  expect{ conjur_authenticate_from_json(last_json) }.not_to raise_error
end
