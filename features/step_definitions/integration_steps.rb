Given(/^I login to PCF and target my organization and space$/) do
  login_to_pcf

  cf_target('ci', 'conjur-service-broker')
end

Given(/^I load a secret into Conjur$/) do
  store_secret_in_remote_conjur("#{ENV['PCF_CONJUR_ACCOUNT']}:variable:app/database/username", ci_secret_user)
  store_secret_in_remote_conjur("#{ENV['PCF_CONJUR_ACCOUNT']}:variable:app/database/password", ci_secret_pass)
end

Given(/^I install the service broker$/) do
  install_service_broker
end

Given(/^I create a service instance for Conjur$/) do
  `cf create-service cyberark-conjur community conjur`
end

Given(/^I load policy to define my org and space$/) do
  load_space_policy_in_remote_conjur('ci', 'conjur-service-broker')
end

When(/^I push the sample app to PCF$/) do
  `cf delete hello-world -f`
  Dir.chdir(integration_test_app_dir) do
    `cf push --no-start --random-route`
  end
end

When(/^I privilege the app to access the secret in Conjur$/) do
  entitle_host_in_remote_conjur(app_bind_id)
end

When(/^I start the app$/) do
  Dir.chdir(integration_test_app_dir) do
    `cf start hello-world`
  end
end

Then(/^I can retrieve the secret value from the app$/) do
  page_content = ci_app_content
  expect(page_content).to match(/Database Username: #{ci_secret_user}/)
  expect(page_content).to match(/Database Password: #{ci_secret_pass}/)
end