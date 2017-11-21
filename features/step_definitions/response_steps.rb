Then(/^the HTTP response status code is "(\d+)"$/) do |status|
  expect(@response.code).to eq(status.to_i)
end

Then /^the result is not empty$/ do
  expect(@result).not_to be_empty
end

Then(/^there is a list of services$/) do
  expect(@result).to have_key("services")
end

Then(/^one of the services is "([^"]*)"$/) do |expected_service|
  have_service = false
  @result["services"].each do |service|
    expect(service).to have_key("name")
    if (service["name"] == expected_service)
      have_service = true
    end
  end

  expect(have_service).to be true
end
