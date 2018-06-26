Before("@conjur-version-5") do
  skip_this_scenario unless ENV['CONJUR_VERSION'] == "5"
end
