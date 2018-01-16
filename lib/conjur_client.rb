require 'conjur-api'
require 'openssl'

class ConjurClient
  class << self
    def api
      @@client.api
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
      ENV['CONJUR_SSL_CERTIFICATE']
    end
  end

  def api
    if defined? @error
      raise @error
    end
    @api
  end

  def initialize
    Conjur.configure do |config|
      config.account = ConjurClient.account
      config.appliance_url = ConjurClient.appliance_url
    end

    if ConjurClient.ssl_cert
      certificate = OpenSSL::X509::Certificate.new ConjurClient.ssl_cert
      OpenSSL::SSL::SSLContext::DEFAULT_CERT_STORE.add_cert certificate
    end

    @api = Conjur::API.new_from_key ConjurClient.authn_login, Conjur::API.rotate_api_key(ConjurClient.authn_login, ConjurClient.authn_api_key)
  rescue => e
    @error = e
  end

  @@client = ConjurClient.new
end
