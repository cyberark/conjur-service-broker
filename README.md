The Conjur Service Broker makes it easy for you to secure credentials used by applications deployed in Cloud Foundry (CF) with CyberArk Conjur. Using the Conjur Service Broker, your CF applications will automatically assume a Conjur Host identity on deploy that will enable them to securely access secret values stored in Conjur.

You will need to have an existing Conjur installation in order to use the Conjur Service Broker; for more information about installing Conjur, please visit [conjur.org](http://conjur.org) or check out our [GitHub repository](https://github.com/cyberark/conjur).

The Conjur Service Broker is an implementation of the [Open Service Broker API](https://www.openservicebrokerapi.org/) (version 2.13).

#### Table of Contents
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## <a name="installation"> Installation Instructions

The instructions that follow will guide you through installing the Conjur Service Broker
and the Conjur Buildpack. The [Conjur Buildpack](https://github.com/cyberark/cloudfoundry-conjur-buildpack)
is a decorator buildpack that installs [Summon](https://cyberark.github.io/summon/)
on application start, and uses Summon to securely inject secret values into your
application's environment. Using the Conjur Buildpack is a convenient way to
securely deliver the secrets that your application needs.

The Conjur Buildpack and Conjur Service Broker should be installed by an admin
Cloud Foundry user. If you follow the instructions below, your CF installation
will be configured so that CF users in any org / space will be able to see the
Conjur service listing when they run `cf marketplace`. For more information on how
to use the Conjur Service Broker when deploying applications, see the
[usage instructions](#service-broker-usage).

### Installing the Conjur Service Broker

**Before you begin, ensure you are logged into your CF deployment via the CF CLI.**

You will need to target the org and space where you want the Service Broker application to run.

Begin by pushing the Service Broker application to CF:
```
git clone git@github.com:conjurinc/conjur-service-broker.git
cd conjur-service-broker
cf push --no-start --random-route
```

The Conjur Service Broker uses HTTP basic authentication, and the credentials it uses must be stored as environment variables in the Service Broker app:
```
cf set-env conjur-service-broker SECURITY_USER_NAME [value]
cf set-env conjur-service-broker SECURITY_USER_PASSWORD [value]
```

To configure the Service Broker to communicate with your external Conjur instance, the Service Broker app requires the following environment variables:
- `CONJUR_VERSION`: the version of your Conjur instance (`4` or `5`); defaults to 5.

- `CONJUR_ACCOUNT`: the account name for the Conjur instance you are connecting to.

- `CONJUR_APPLIANCE_URL`: the URL of the Conjur appliance instance you are connecting to. When using an HA Conjur master cluster, this should be the URL of the master load balancer.

- `CONJUR_FOLLOWER_URL` (HA only): If using high availability, this should be the URL for a load balancer that manages the cluster's Follower instances. This is the URL that applications that bind to the service broker will use to communicate with Conjur.

- `CONJUR_POLICY`: the Policy where new Hosts should be added - the Conjur account specified in `CONJUR_AUTHN_LOGIN` needs `create` and `update` privilege on this Policy.
  > **NOTE:** The `CONJUR_POLICY` is optional, but is strongly recommended. By default, if this value is not specified, Hosts will be added to the `root` Conjur policy, and the Conjur account that the Service Broker uses to manage the Hosts will need `create` and `update` privileges on the `root` Conjur policy.

  > **NOTE:** If you use multiple CloudFoundry foundations, this policy should include an identifier for the foundation to distinguish applications deployed in each. For example, if you have both a `production` and `development` foundation, then your policy branches for the Conjur Service Broker might be `cf/prod` and `cf/dev`.

  > **NOTE:** If you are using v4 Conjur, the Service Broker requires your `CONJUR_POLICY` to have a Host Factory called `CONJUR_POLICY-apps`. For example, if your `CONJUR_POLICY` is `cf/prod`, you can add a Host Factory by updating your  policy file to include the following:
  > ```yaml
  > - !policy
  >   id: cf
  >   body:
  >     - !policy prod
  >       owner: !group cf-admin-group
  >       body:
  >       - !layer cf/prod-apps
  > 
  >       - !host-factory
  >         id: cf/prod-apps
  >         layers: [ !layer cf/prod-apps ]
  > ```
  > 
  > If you do not specify a `CONJUR_POLICY` (this is not recommended) in your Service Broker configuration and you are using > `CONJUR_VERSION` 4, then you will need to add a Host Factory to the `root` Conjur policy by including:
  > ```yaml
  > - !layer apps
  > 
  > - !host-factory
  >   id: apps
  >   layers: [ !layer apps ]
  > ```
  > 

- `CONJUR_AUTHN_LOGIN`: the identity of a Conjur Host (of the form `host/host-id`) with `create` and `update` privileges on `CONJUR_POLICY`. This account will be used to add and remove Hosts from Conjur policy as apps are deployed to or removed from PCF.

  If you are using Enterprise Conjur, you will want to add an annotation on the Service Broker Host in policy to indicate which platform the Service Broker will be used on. The policy you load may look something like:
  ```yaml
  - !host
    id: cf-service-broker
    annotations:
      platform: cloudfoundry
  ```
  You may elect to set `platform` to `cloudfoundry` or to `pivotalcloudfoundry`, for example. This annotation will be used to set annotations on Hosts added by the Service Broker, so that they will show in the Conjur UI with the appropriate platform logo.

  > **NOTE:** The `CONJUR_AUTHN_LOGIN` value for the Host created in policy above is `host/cf-service-broker`.

- `CONJUR_AUTHN_API_KEY`: the API Key of the Conjur Host whose identity you have provided in `CONJUR_AUTHN_LOGIN`.

- `CONJUR_SSL_CERTIFICATE`: the x509 certificate that was created when Conjur was initiated; this is required for v4 Conjur, but is optional otherwise. If the certificate is stored in a PEM file, you can load it into a local environment variable by calling `export CONJUR_SSL_CERTIFICATE="$(cat tmp/conjur.pem)"`.

- `ENABLE_SPACE_IDENTITY`: When set to the value `true`, the service broker will provide applications with a Space-level `host` identity, rather than create a new `host` identity for the application in Conjur at bind time. This allows the broker to use a Conjur follower for application binding, rather than the Conjur master.

To load these environment variables into the Service Broker's environment, run:
```
cf set-env conjur-service-broker CONJUR_VERSION [value]
cf set-env conjur-service-broker CONJUR_ACCOUNT [value]
cf set-env conjur-service-broker CONJUR_APPLIANCE_URL [value]
cf set-env conjur-service-broker CONJUR_AUTHN_LOGIN [value]
cf set-env conjur-service-broker CONJUR_AUTHN_API_KEY [value]
cf set-env conjur-service-broker CONJUR_POLICY [value]
cf set-env conjur-service-broker CONJUR_SSL_CERTIFICATE [value]
cf set-env conjur-service-broker ENABLE_SPACE_IDENTITY [value]
```

Once the Service Broker is configured, start the Service Broker application
```
cf start conjur-service-broker
```
and register it with the same Basic Auth credentials specified in your environment variables:
```
APP_URL="http://`cf app conjur-service-broker | grep -E -w 'urls:|routes:' | awk '{print $2}'`"
cf create-service-broker conjur-service-broker "[username value]" "[password value]" $APP_URL
```
When the Service Broker application is started, it will run a health check that validates its connection to your Conjur instance, including checking that the Host Factory exists if you are using Conjur version 4.

To make the Conjur service listing available in the marketplace in all orgs and spaces, run
```
cf enable-service-access cyberark-conjur
```

If you have reached this point, the Conjur Service Broker has been successfully
deployed to your Cloud Foundry installation.

### Installing the Conjur Buildpack

The Conjur Buildpack uses [Summon](https://cyberark.github.io/summon/) to load secrets into the environment of CF-deployed applications based on the app's `secrets.yml` file. For instructions on installing and using the Conjur Buildpack, please [see the Conjur Buildpack documentation](https://github.com/cyberark/cloudfoundry-conjur-buildpack).


## <a name="usage"> Service Broker Usage

Once the Service Broker is installed, you should see the service listing from any
org / space:
```
$ cf marketplace
Getting services from marketplace in org cyberark-conjur-org / space cyberark-conjur-space as admin...
OK

service             plans                  description
cyberark-conjur     community              An open source security service that provides secrets management, machine-identity based authorization, and more.

TIP:  Use 'cf marketplace -s SERVICE' to view descriptions of individual plans of a given service.
```

When you are ready to use the Conjur Service Broker, you can create a Conjur
service instance under the `community` plan in the org / space where you will be
deploying your application:
```
cf create-service cyberark-conjur community conjur
```

> **NOTE:** Service instances cannot be shared between spaces. A Conjur
service instance must be created in each space where apps retrieve secrets
from Conjur.

For PCF 2.0+, when the service broker is provisioned in a space, it will automatically create
a policy branch for the org and space if it doesn't already exist. The policy will look similar to
this:

```yaml
---
# Policy for the Organization
- !policy
  # Organization GUID from PCF.
  # This may be obtained by running `cf org --guid {org name}
  id: cbd7a05a-b304-42a9-8f66-6827ae6f78a1
  body:
    # Layer to allow privileging an entire organzation to a resource
    - !layer

    # Policy for the Space
    - !policy
      # Space GUID from PCF.
      # This may be obtained by running `cf space --guid {space name}
      id: 8bf39f4a-ebde-437b-9c38-3d234b80631a
      body:
        # Layer to allow privileging an entire space to a resource
        # The service broker will add applications to this layer automatically.
        - !layer

    # Grant to add the Space layer to the Org Layer
    - !grant
      role: !layer
      member: !layer 8bf39f4a-ebde-437b-9c38-3d234b80631a
```

### Create a `secrets.yml` File

To leverage the Conjur Buildpack so that secret values will automatically be
injected into your application's environment at runtime, a `secrets.yml` file is
required. The `secrets.yml` file gives a mapping of **environment variable name**
to a **location where a secret is stored in Conjur**. For more information about
creating this file, [see the Summon documentation](https://cyberark.github.io/summon/#secrets.yml).

### Bind Your Application to the Conjur Service

Binding your application to the `conjur` service instance provides the application with an
identity in Conjur, and credentials that it may use to retrieve secrets.

To bind your application to the `conjur` service using the CLI, run the command:
```
cf bind-service my-app conjur
```

Alternatively you can specify the conjur service in your application manifest:
```
---
applications:
- name: my-app
  services:
  - conjur
```

#### Application vs Space Host Identity

The service broker may be configured to either create a single Conjur identity shared by
all applications in a space, or to create a Conjur identity for each application
separately.

In PCF version 2.0+, when the service broker creates the identity for your application
in Conjur, it will automatically add it to a Conjur Layer representing the `Organization`
and `Space` where the application is deployed. These layers may be used for control secret
access at the org or space level, rather than the application host itself.

##### Space-scoped Identity

Space-scoped identities are enabled by configuring the service broker with
`ENABLE_SPACE_IDENTITY` set to `true`. This means that when a service instance is created
in a space, the service broker will create a Conjur Host for that space. When an application
is bound to the service, the service broker will give it the credentials of the space identity,
rather than create a new host identity for the application.

The advantage to this is the bind operation only requires access to a Conjur follower and
not the Conjur master. This promotes high-availability and scalability of app binding and secret
retrieval.

##### Application-scoped Identity

When space identities are not enabled, the service broker will create a new Conjur host identity
for each application bound to the service. This requires that the service broker is able to
communicate with the Conjur master for each bind request.

The advantage to this is finer-grained access control and audit logs in Conjur.

### Granting Application Access to Secrets

PCF applications can be granted access to secrets using either the Org and Space layers,
or with the application host identity.

#### Privilege Org and Space Layers

Applications can be granted access to secrets by privileging the Org or Space layers
to read secrets using Conjur policy.

The layer Ids use the Org and Space GUID identifiers, which may be obtained
using the Cloud Foundry CLI:
```sh-session
$ cf org --guid <org-name>
6b40649e-331b-424d-afa0-6d569f016f51

$ cf space --guid <space-name>
72a928f6-bf7c-4732-a195-896f67bd1133
```

For example, the policy to privilege a space to access a secret is:
```yaml
- !permit
  resource: my-secret-id
  role: !layer cf/prod/6b40649e-331b-424d-afa0-6d569f016f51/72a928f6-bf7c-4732-a195-896f67bd1133
  privileges: [ read, execute ]
```

#### Privilege Application Host Identity

> **NOTE:** Application Host privileging is not available when using Space Host Identies.

After your application has been pushed to PCF, you can use its host identity in
Conjur policy to grant it access to secrets.

The host identity of the application is stored in the `authn_login` field in the `cyberark-conjur`
credentials in the application's environment, and might look something like
`host/cf/prod/0299a19d-7de4-4e98-89f6-372ac7c0521f`.

  > **NOTE**: In PCF version 2.0+, the host identity will include the Organization and Space GUIDs in
  the Host identity, for example:

  ```
  host/cf/prod/cbd7a05a-b304-42a9-8f66-6827ae6f78a1/8bf39f4a-ebde-437b-9c38-3d234b80631a/c363669e-e43b-40b9-b650-493d3bdb4663
  ```

### Run Your Application

Now that your application is privileged to access the secrets it needs in Conjur,
start or restage the app so that the Conjur Buildpack can inject the secret values
into the running application's environment.

The secrets are now available to be used by the application, but are not visible
when you run `cf env my-app` or if you `cf ssh my-app` and run `printenv`.

### Rotating Host API Keys

When the API key for a PCF application host is rotated, the application will need to be rebound
to the Conjur service instance to receive the new credentials, and then restaged to fetch secret
values using the new credentials.

> **NOTE:** When using Space Host Identities, the new API key for the Space Host needs to be updated
> in a Conjur variable for the Space policy. The command to do this is:
```
conjur variable values add "<cf policy root>/<org-guid>/<space-guid>/space-host-api-key" "<api-key-value>"

# For example:
conjur variable values add "cf/prod/6b40649e-331b-424d-afa0-6d569f016f51/72a928f6-bf7c-4732-a195-896f67bd1133/space-host-api-key" "1p9c5443sy1bg93ek2e062wsnmvy3p9k9j83nq841sj1sp2vasze1r"
```

To rebind the application to Conjur, run these commands using the Cloud Foundry CLI:
```sh
cf unbind-service <app-name> conjur
cf bind-service <app-name> conjur
```

To restage the application, run this command:
```
cf restage <app-name>
```

> **NOTE:** If using Space Host Identities, these commands need to be run for each application
> in the space.

## <a name="contributing"> Contributing

Information for developing and testing the service broker can be found in the
[Contributing Guide](CONTRIBUTING.md).

## <a name="license"> License

Copyright 2018 CyberArk

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
