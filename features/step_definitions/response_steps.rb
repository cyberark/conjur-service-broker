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
  store_json_response(memory_id)

  if negate
    expect{ authenticate_from_json(@response_json) }.to raise_error(ConjurOpenApi::ApiError)
  else
    expect{ authenticate_from_json(@response_json) }.not_to raise_error
  end
end

And(/^the JSON has valid conjur credentials$/) do
  expect{ authenticate_from_json(last_json) }.not_to raise_error
end

And(/^the host in "([^"]*)" has annotation "([^"]*)" in Conjur$/) do |memory_id, annotation|
  store_json_response(memory_id)
  annotation_hash = JSON.parse("{ #{annotation.gsub("'", '"')} }")

  has_annotation = false
  host_annotations.each do |host_annotation|
    host_annotation_hash = { "#{host_annotation[:name]}" => host_annotation[:value] }
    has_annotation = true if host_annotation_hash == annotation_hash
  end

  expect(has_annotation).to be true
end
