require 'openssl'
require 'conjur-sdk'

class ConjurConfig
  class ConjurAuthenticationError < RuntimeError
  end

  class << self
    def check_version
      case ConjurSDK.version
      when 4
        raise 'Conjur Enterprise v4 is no longer supported. Please use Conjur Service Broker v1.1.4 or earlier.'
      when 5
        5
      else
        raise 'Invalid value for CONJUR_VERSION'
      end
    end

    def login_host_id
      config.username.sub /^host\//, "" if login_is_host?
    end

    def login_is_host?
      config.username.include?("host\/")
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
      puts "config: #{config}, #{config.class}"
      platform_annotation = ""
      if !login_host_id.nil?
        resources_api = ConjurSDK::ResourcesApi.new client
        resource = resources_api.show_resource(config.account, "host", login_host_id)
        resource[:annotations].each do |annotation|
          platform_annotation = annotation[:value] if annotation[:name] == "platform"
        end
      end
      
      return platform_annotation
    end

    def config(base_url=appliance_url)
      ConjurSDK.configure do |config|
        config.host = base_url
        config.setup_access_token
        @@config ||= config
      end
      @@config
    end

    def client(base_url=appliance_url)
      return ConjurSDK::ApiClient.new config(base_url)
    end
  end
end
