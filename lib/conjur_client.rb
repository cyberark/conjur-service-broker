require 'conjur-api'
require 'openssl'

class ConjurClient

  class ConjurAuthenticationError < RuntimeError
  end

  class << self
    def api
      ConjurClient.new.api(appliance_url)
    end

    # Returns an API object that may be read-only. It will use
    # the Conjur Follower URL when available.
    def readonly_api
      ConjurClient.new.api(ConjurClient.application_conjur_url)
    end

    def v5?
      version == 5
    end

    def version
      case ENV['CONJUR_VERSION']
      when "4"
        raise 'Conjur Enterprise v4 is no longer supported. Please use Conjur Service Broker v1.1.4 or earlier.'
      when "5", "", nil
        5
      else
        raise 'Invalid value for CONJUR_VERSION'
      end
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

    def login_host_id
      authn_login.sub /^host\//, "" if login_is_host?
    end

    def login_is_host?
      authn_login.include?("host\/")
    end

    def appliance_url
      ENV['CONJUR_APPLIANCE_URL']
    end

    def application_conjur_url
      ENV['CONJUR_FOLLOWER_URL'].presence || appliance_url
    end

    def policy
      ENV['CONJUR_POLICY'].presence || 'root'
    end

    def ssl_cert
      ENV['CONJUR_SSL_CERTIFICATE'] unless ENV['CONJUR_SSL_CERTIFICATE'].blank?
    end

    def platform
      platform_annotation = ""
      if !login_host_id.nil?
        host = api.resource("#{account}:host:#{login_host_id}")
        JSON.parse(host.attributes["annotations"].to_json).each do |annotation|
          platform_annotation = annotation["value"] if annotation["name"] == "platform"
        end
      end
      
      return platform_annotation
    end
  end

  def api(appliance_url)
    Conjur.configure do |config|
      config.account = ConjurClient.account
      config.appliance_url = appliance_url
      config.ssl_certificate = ConjurClient.ssl_cert
      config.version = ConjurClient.version
    end

    Conjur.configuration.apply_cert_config!

    Conjur::API.new_from_key ConjurClient.authn_login,
                             ConjurClient.authn_api_key
  end
end
