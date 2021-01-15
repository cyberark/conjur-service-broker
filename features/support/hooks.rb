Before("@conjur-version-5") do
  skip_this_scenario unless ENV['CONJUR_VERSION'] == "5"
end

After("@integration") do |scenario|
  cleanup_service_broker
  cf_delete_org(cf_ci_org)
end

Before("@enable-space-host") do
  @space_host_enabled = true
end

Before("~@enable-space-host") do
  @space_host_enabled = false
end
