Then(/^the JSON at "([^"]*)" should be the master address$/) do |path|
  step "the JSON at \"#{path}\" should be \"#{ENV['CONJUR_APPLIANCE_URL']}\""
end
