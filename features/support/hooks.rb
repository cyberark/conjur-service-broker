Before("@conjur-version-5") do
  skip_this_scenario unless ENV['CONJUR_VERSION'] == "5"
end

Before("@conjur-version-4") do
  skip_this_scenario unless ENV['CONJUR_VERSION'] == "4"
end

Before("@service-broker") do |scenario|
  login_to_pcf
  cf_target(cf_ci_org, cf_ci_space)

  install_service_broker
end

After("@service-broker") do
  cf_target(cf_ci_org, cf_ci_space)
  cleanup_service_broker
end
