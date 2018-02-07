require 'conjur-api'
require 'openssl'

class ConjurClient
  class << self
    def api
      ConjurClient.new.api
    end

    def v4_host_factory_id
      "#{account}:host_factory:#{policy}/#{policy}-apps"
    end

    def version
      (ENV['CONJUR_VERSION'] || 5).to_i
    end

    def account
      ENV['CONJUR_ACCOUNT']
    end
  
    def authn_api_key
      ENV['CONJUR_AUTHN_API_KEY']
    end
  
    def authn_login
      ENV['CONJUR_AUTHN_LOGIN']
    end
  
    def appliance_url
      ENV['CONJUR_APPLIANCE_URL']
    end

    def policy
      ENV['CONJUR_POLICY'] || 'root'
    end
  
    def ssl_cert
      ENV['CONJUR_SSL_CERTIFICATE'] unless ENV['CONJUR_SSL_CERTIFICATE'].blank?
    end
  end

  def api
    Conjur.configure do |config|
      config.account = ConjurClient.account
      config.appliance_url = ConjurClient.appliance_url
      config.ssl_certificate = ConjurClient.ssl_cert
      config.version = ConjurClient.version
    end

    Conjur.configuration.apply_cert_config!

    Conjur::API.new_from_key ConjurClient.authn_login, 
                             ConjurClient.authn_api_key
  end
end
