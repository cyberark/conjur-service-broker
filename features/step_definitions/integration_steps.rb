Given(/^I login to PCF and target my organization and space$/) do
  login_to_pcf
  cf_target(cf_ci_org, cf_ci_space)
end

Given(/^I load a secret into Conjur$/) do
  store_secret_in_remote_conjur("#{ENV['PCF_CONJUR_ACCOUNT']}:variable:app/secrets/org", ci_secret_org)
  store_secret_in_remote_conjur("#{ENV['PCF_CONJUR_ACCOUNT']}:variable:app/secrets/space", ci_secret_space)
  store_secret_in_remote_conjur("#{ENV['PCF_CONJUR_ACCOUNT']}:variable:app/secrets/app", ci_secret_app)
end

Given(/^I create a service instance for Conjur$/) do
  cf_target(cf_ci_org, cf_ci_space)
  `cf create-service cyberark-conjur community conjur`
end

When(/^I push the sample app to PCF$/) do
  cf_target(cf_ci_org, cf_ci_space)

  `cf delete hello-world -f`
  Dir.chdir(integration_test_app_dir) do
    `cf push --no-start --random-route`
  end
end

When(/^I start the app$/) do
  cf_target(cf_ci_org, cf_ci_space)

  Dir.chdir(integration_test_app_dir) do
    `cf start hello-world`
  end
end

Then(/^I can retrieve the secret values from the app$/) do
  page_content = ci_app_content
  expect(page_content).to match(/Org Secret: #{ci_secret_org}/)
  expect(page_content).to match(/Space Secret: #{ci_secret_space}/)
  expect(page_content).to match(/App Secret: #{ci_secret_app}/)
end

Then(/^the policy for the org and space( doesn't)? exist(?:s)?$/) do |negative|
  expect(remote_conjur_resource_exists?(org_policy_id)).to eq(negative.blank?)
  expect(remote_conjur_resource_exists?(space_policy_id)).to eq(negative.blank?)
end

When(/^I privilege the org layer to access a secret in Conjur$/) do
  role = "!layer pcf/ci/#{org_guid(cf_ci_org)}"
  secret = "!variable app/secrets/org"
  privilege_in_remote_conjur(role, secret)
end

When(/^I privilege the space layer to access a secret in Conjur$/) do
  role = "!layer pcf/ci/#{org_guid(cf_ci_org)}/#{space_guid(cf_ci_org, cf_ci_space)}"
  secret = "!variable app/secrets/space"
  privilege_in_remote_conjur(role, secret)
end

When(/^I privilege the app host to access a secret in Conjur$/) do
  role = "!host pcf/#{app_bind_id}"
  secret = "!variable app/secrets/app"
  privilege_in_remote_conjur(role, secret)
end

When(/^I remove the service instance$/) do
  cf_target(cf_ci_org, cf_ci_space)

  `cf unbind-service hello-world conjur`
  `cf delete-service conjur -f`
end
