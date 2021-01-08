module CfHelper
  def unpack_and_push_service_broker(cli)
    Dir.chdir('/app') do
      cli.execute('mkdir -p ./pkg')
      cli.execute('unzip -n cyberark-conjur-service-broker_$(cat VERSION).zip -d ./pkg')
      Dir.chdir('./pkg') do
        cli.execute('cf push --no-start --random-route')
      end
    end
  end

  def install_service_broker
    cf = ShellSession.new
    
    # Push this version of the service broker
    unpack_and_push_service_broker(cf)

    # Configure the service broker
    api_key = rotate_api_key("#{ENV['PCF_CONJUR_ACCOUNT']}:host:pcf/service-broker")

    broker_environment = {
      'SECURITY_USER_NAME' => service_broker_user,
      'SECURITY_USER_PASSWORD' => service_broker_pass,
      'CONJUR_ACCOUNT' => ENV['PCF_CONJUR_ACCOUNT'],
      'CONJUR_APPLIANCE_URL' => ENV['PCF_CONJUR_APPLIANCE_URL'],
      'CONJUR_AUTHN_LOGIN' => 'host/pcf/service-broker',
      'CONJUR_AUTHN_API_KEY' => api_key,
      'CONJUR_VERSION' => '5',
      'CONJUR_POLICY' => 'pcf/ci',
      'CONJUR_SSL_CERTIFICATE' => ENV['PCF_CONJUR_SSL_CERT']
    }

    if @space_host_enabled
      broker_environment['ENABLE_SPACE_IDENTITY'] = 'true'
    end

    broker_environment.each do |key, value|
      cf.execute(%(cf set-env conjur-service-broker #{key} "#{value}"))
    end

    # Start the service broker and make it available
    cf.execute("cf start conjur-service-broker")
    sb_url="https://#{`cf app conjur-service-broker | grep -E -w 'urls:|routes:' | awk '{print $2}'`}"
    cf.execute(%(cf create-service-broker --space-scoped "#{cf_ci_service_broker_name}" "#{service_broker_user}" "#{service_broker_pass}" #{sb_url}))
  end

  def cleanup_service_broker
    ShellSession.execute("cf purge-service-instance conjur -f")
                .execute(%(cf delete-service-broker "#{cf_ci_service_broker_name}" -f))
                .execute('cf delete conjur-service-broker -f -r')
  end

  def org_guid(org_name)
    ShellSession.execute(%(cf org --guid "#{org_name}")).output.chomp
  end

  def space_guid(org_name, space_name)
    cf_target(org_name, space_name)
    ShellSession.execute(%(cf space --guid "#{space_name}")).output.chomp
  end

  def app_bind_id
    ShellSession.execute(<<~SHELL
      cf env hello-world | \
      grep authn_login | \
      awk '{print $NF}' | \
      sed 's/host\\/pcf\\///g; s/"//g; s/,$//g'
    SHELL
                        ).output.strip!
  end

  def login_to_pcf
    api_endpoint = ENV['CF_API_ENDPOINT']

    cf_api(api_endpoint)
    cf_auth(ci_user[:username], ci_user[:password])
  end

  def create_ci_user
    cf_target(cf_ci_org, cf_ci_space)
    cf_auth('admin', ENV['CF_ADMIN_PASSWORD'])

    username = "ci-user-#{SecureRandom.hex}"
    password = SecureRandom.hex

    ShellSession.execute(%(cf create-user "#{username}" "#{password}"))
                .execute(%(cf set-space-role "#{username}" "#{cf_ci_org}" "#{cf_ci_space}" "SpaceDeveloper"))

    {
      username: username,
      password: password
    }
  end

  def admin_user
    @admin_user ||= {
      username: 'admin',
      password: CF_ADMIN_PASSWORD
    }
  end

  def create_org
    cf_auth('admin', ENV['CF_ADMIN_PASSWORD'])

    name = "ci-org-#{SecureRandom.hex}"
    ShellSession.execute(%(cf create-org #{name}))
    name
  end

  def cf_delete_org(org_name)
    cf_auth('admin', ENV['CF_ADMIN_PASSWORD'])
    ShellSession.execute(%(cf delete-org -f #{org_name}))
  end

  def create_space(org = nil)
    name = "ci-space-#{SecureRandom.hex}"
    ShellSession.execute(%(cf create-space #{name} #{"-o #{org}" if org}))
    name
  end

  def ci_app_route
    route = ShellSession.execute(<<~SHELL
      cf app hello-world | \
      awk -F ':' -v key="routes" '$1==key {print $2}'
    SHELL
                                ).output.strip!
      
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
    ShellSession.execute(%(cf api "#{api}" --skip-ssl-validation))
  end

  def cf_auth(user, password)
    ShellSession.execute(%(cf auth "#{user}"), "CF_PASSWORD" => password)
  end

  def cf_target(org, space=nil)
    if space
      ShellSession.execute(%(cf target -o "#{org}" -s "#{space}"))
    else
      ShellSession.execute(%(cf target -o "#{org}"))
    end
  end

  def cf_service_instance_id
    @cf_service_instance_id ||= ShellSession.execute(%(cf service --guid conjur)).output.chomp
  end
end
