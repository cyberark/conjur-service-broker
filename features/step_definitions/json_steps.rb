Then(/^the JSON at "([^"]*)" should be the master address$/) do |path|
  step "the JSON at \"#{path}\" should be \"#{ENV['CONJUR_APPLIANCE_URL']}\""
end

Then(/^the JSON at "([^"]*)" should be the follower address$/) do |path|
  step "the JSON at \"#{path}\" should be \"#{ENV['CONJUR_FOLLOWER_URL']}\""
end
