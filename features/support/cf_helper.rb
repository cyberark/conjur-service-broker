module CfHelper
  def install_service_broker(preserve)
    output = []

    # Push this version of the service broker
    Dir.chdir('/app') do
      output << `cf push --no-start --random-route`
    end

    # Configure the service broker
    api_key = rotate_api_key("#{ENV['PCF_CONJUR_ACCOUNT']}:host:pcf/service-broker")
    output << `cf set-env conjur-service-broker SECURITY_USER_NAME "#{service_broker_user}"`
    output << `cf set-env conjur-service-broker SECURITY_USER_PASSWORD "#{service_broker_pass}"`
    output << `cf set-env conjur-service-broker CONJUR_ACCOUNT "#{ENV['PCF_CONJUR_ACCOUNT']}"`
    output << `cf set-env conjur-service-broker CONJUR_APPLIANCE_URL "#{ENV['PCF_CONJUR_APPLIANCE_URL']}"`
    output << `cf set-env conjur-service-broker CONJUR_AUTHN_LOGIN "host/pcf/service-broker"`
    output << `cf set-env conjur-service-broker CONJUR_AUTHN_API_KEY "#{api_key}"`
    output << `cf set-env conjur-service-broker CONJUR_VERSION "5"`
    output << `cf set-env conjur-service-broker CONJUR_POLICY "pcf/ci"`
    output << `cf set-env conjur-service-broker CONJUR_SSL_CERTIFICATE "#{ENV['PCF_CONJUR_SSL_CERT']}"`
    output << `cf set-env conjur-service-broker CONJUR_PRESERVE_POLICY "#{preserve.to_s}"`

    
    # Start the service broker and make it available
    output << `cf start conjur-service-broker`
    sb_url="https://#{`cf app conjur-service-broker | grep -E -w 'urls:|routes:' | awk '{print $2}'`}"
    output << `cf create-service-broker --space-scoped "#{cf_ci_service_broker_name}" "#{service_broker_user}" "#{service_broker_pass}" #{sb_url}`
  rescue => ex
    puts output.join("\n")
    raise
  end

  def cleanup_service_broker
    output = []
    output << `cf purge-service-instance conjur -f`
    output << `cf delete-service-broker "#{cf_ci_service_broker_name}" -f`
    output << `cf delete conjur-service-broker -f`
  end

  def org_guid(org_name)
    `cf org --guid "#{org_name}"`.chomp
  end

  def space_guid(org_name, space_name)
    `cf target -o "#{org_name}"`
    `cf space --guid "#{space_name}"`.chomp
  end

  def app_bind_id
    `cf env hello-world | grep authn_login | awk '{print $NF}' | sed 's/host\\/pcf\\///g; s/"//g; s/,$//g'`.strip!
  end

  def login_to_pcf
    api_endpoint = ENV['CF_API_ENDPOINT']
    ci_user = ENV['CF_CI_USER']
    ci_password = ENV['CF_CI_PASSWORD']

    cf_api(api_endpoint)
    cf_auth(ci_user, ci_password)
  end

  def ci_app_route
    route = `cf app hello-world | awk -F ':' -v key="routes" '$1==key {print $2}'`.strip!
    "https://#{route}/"
  end

  def ci_app_content
    uri = URI(ci_app_route)
    req = Net::HTTP::Get.new(uri.path)

    res = Net::HTTP.start(
            uri.host, uri.port, 
            :use_ssl => uri.scheme == 'https', 
            :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |https|
      https.request(req)
    end

    res.body.strip!
  end

  def cf_api(api)
    `cf api "#{api}" --skip-ssl-validation`
  end

  def cf_auth(user, password)
    system({"CF_PASSWORD" => password}, "cf auth '#{user}'")
  end

  def cf_target(org, space)
    `cf target -o "#{org}" -s "#{space}"`
  end

  def cf_service_instance_id
    @cf_service_instance_id ||= `cf service --guid conjur`.chomp
  end
end
