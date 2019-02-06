module ConjurHelper
  def conjur_authenticate_from_json auth_json
    account = parse_json(auth_json, 'credentials/account')
    appliance_url = parse_json(auth_json, 'credentials/appliance_url')
    login = parse_json(auth_json, 'credentials/authn_login')
    api_key = parse_json(auth_json, 'credentials/authn_api_key')
    version = parse_json(auth_json, 'credentials/version')
    ssl_cert = parse_json(auth_json, 'credentials/ssl_certificate')

    Conjur.with_configuration Conjur::Configuration.new(
      account: account,
      appliance_url: appliance_url,
      ssl_certificate: ssl_cert,
      version: version
    ) do
      Conjur.configuration.apply_cert_config!
      Conjur::API.authenticate(login, api_key)
    end
  end

  def rotate_api_key(id)
    remote_conjur do |api|
      api.role(id).rotate_api_key
    end
  end

  def remote_conjur_resource_exists?(id)
    remote_conjur do |api|
      api.resource(id).exists?
    end
  end

  def store_secret_in_remote_conjur(var_id, value)
    remote_conjur do |api|
      api.resource(var_id).add_value(value)
    end
  end

  def remote_conjur
    Conjur.with_configuration Conjur::Configuration.new(
      account: ENV['PCF_CONJUR_ACCOUNT'],
      appliance_url: ENV['PCF_CONJUR_APPLIANCE_URL'],
      ssl_certificate: ENV['PCF_CONJUR_SSL_CERT'],
      version: 5
    ) do
      Conjur.configuration.apply_cert_config!

      api = Conjur::API.new_from_key ENV['PCF_CONJUR_USERNAME'], ENV['PCF_CONJUR_API_KEY']

      yield api
    end
  end
end