require 'conjur-api'
require 'openssl'
require 'conjur-sdk'

class OpenapiConfig
  class ConjurAuthenticationError < RuntimeError
  end

  class << self
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
      follower_url = ENV['CONJUR_FOLLOWER_URL']
      if follower_url.nil? || follower_url.empty?
        appliance_url
      else
        follower_url
      end
    end

    def policy_name
      policy = ENV['CONJUR_POLICY']
      if policy.nil? || policy.empty?
        'root'
      else
        policy
      end
    end

    def ssl_cert
      ENV['CONJUR_SSL_CERTIFICATE'] unless ENV['CONJUR_SSL_CERTIFICATE'].blank?
    end

    def platform
      platform_annotation = ""
      if !login_host_id.nil?
        resources_api = ConjurOpenApi::ResourcesApi.new client
        resource = resources_api.show_resource(account, "host", login_host_id)
        resource[:annotations].each do |annotation|
          platform_annotation = annotation[:value] if annotation[:name] == "platform"
        end
      end
      
      return platform_annotation
    end

    def client(base_url=appliance_url)
      ConjurOpenApi.configure do |config|
        config.username = authn_login
        config.host = base_url
        config.ssl_ca_cert = OpenapiConfig.ssl_cert

        authn_instance = ConjurOpenApi::AuthenticationApi.new
        token = authn_instance.get_access_token(
          account,
          authn_login,
          authn_api_key,
          opts={accept_encoding: 'base64'}
        )

        config.api_key_prefix['Authorization'] = 'Token'
        config.api_key['Authorization'] = "token=\"#{token}\""
      end

      return ConjurOpenApi::ApiClient.new
    end
  end
end
