module ServiceBinding
  class RoleAlreadyCreated < RuntimeError
  end

  class HostNotFound < RuntimeError
  end

  class NonExistentServiceBindingClass < RuntimeError
  end

  # Look up table for available service bindings by
  # Conjur version and whether space identities are enabled
  SERVICE_BINDING_CLASSES = {
    5 => {
      true => ::ServiceBinding::ConjurV5SpaceBinding,
      false => ::ServiceBinding::ConjurV5AppBinding
    }
  }.freeze

  class << self
    # Provides the service binding class for the
    # given configuration.
    def from_hash(
      conjur_version:,
      enable_space_identity:
    )
      SERVICE_BINDING_CLASSES.dig(
        conjur_version,
        enable_space_identity
      ).tap do |result|
        unless result
          raise NonExistentServiceBindingClass,
                "There is no service binding for " \
                "conjur_version=#{conjur_version} and " \
                "enable_space_identity=#{enable_space_identity}"
        end
      end
    end

    def build_credentials(host_id, api_key)
      {
        account: OpenapiConfig.account,
        appliance_url: OpenapiConfig.application_conjur_url,
        authn_login: "host/#{host_id}",
        authn_api_key: api_key,
        ssl_certificate: OpenapiConfig.ssl_cert || "",
        version: OpenapiConfig.version
      }
    end
  end
end
