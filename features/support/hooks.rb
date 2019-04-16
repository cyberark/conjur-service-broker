Before("@conjur-version-5") do
  skip_this_scenario unless ENV['CONJUR_VERSION'] == "5"
end

Before("@conjur-version-4") do
  skip_this_scenario unless ENV['CONJUR_VERSION'] == "4"
end

After("@integration") do |scenario|
  if scenario.status == :passed
    cleanup_service_broker
    cf_delete_org(cf_ci_org)
  end
end
