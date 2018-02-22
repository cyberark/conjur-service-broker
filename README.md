The Conjur Service Broker makes it easy for you to secure credentials used by applications deployed in Cloud Foundry (CF) with CyberArk Conjur. Using the Conjur Service Broker, your CF applications will automatically assume a Conjur Host identity on deploy that will enable them to securely access secret values stored in Conjur.

You will need to have an existing Conjur installation in order to use the Conjur Service Broker; for more information about installing Conjur, please visit [conjur.org](http://conjur.org) or check out our [GitHub repository](https://github.com/cyberark/conjur).

The Conjur Service Broker is an implementation of the [Open Service Broker API](https://www.openservicebrokerapi.org/) (version 2.13).

## Installation Instructions

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
- `CONJUR_VERSION`: the version of your Conjur instance (`4` or `5`); defaults to 5
- `CONJUR_ACCOUNT`: the account name for the Conjur instance you are connecting to
- `CONJUR_APPLIANCE_URL`: the URL of the Conjur appliance instance you are connecting to
- `CONJUR_POLICY`: the Policy where new Hosts should be added - the Conjur account specified in `CONJUR_AUTHN_LOGIN` needs `create` and `update` privilege on this Policy.
  - The `CONJUR_POLICY` is optional, but is strongly recommended. By default, if this value is not specified, Hosts will be added to the `root` Conjur policy, and the Conjur account that the Service Broker uses to manage the Hosts will need `create` and `update` privileges on the `root` Conjur policy.
- `CONJUR_AUTHN_LOGIN`: the identity of a Conjur Host (of the form `host/host-id`) with `create` and `update` privileges on `CONJUR_POLICY`. This account will be used to add and remove Hosts from Conjur policy as apps are deployed to or removed from PCF.

  If you are using Enterprise Conjur, you will want to add an annotation on the Service Broker Host in policy to indicate which platform the Service Broker will be used on. The policy you load may look something like:
  ```
  - !host
    id: cf-service-broker
    annotations:
      platform: cloudfoundry
  ```
  You may elect to set `platform` to `cloudfoundry` or to `pivotalcloudfoundry`, for example. This annotation will be used to set annotations on Hosts added by the Service Broker, so that they will show in the Conjur UI with the appropriate platform logo.

  Note: the `CONJUR_AUTHN_LOGIN` value for the Host created in policy above is `host/cf-service-broker`.
- `CONJUR_AUTHN_API_KEY`: the API Key of the Conjur Host whose identity you have provided in `CONJUR_AUTHN_LOGIN`
- `CONJUR_SSL_CERTIFICATE`: the x509 certificate that was created when Conjur was initiated; this is required for v4 Conjur, but is optional otherwise. If the certificate is stored in a PEM file, you can load it into a local environment variable by calling `export CONJUR_SSL_CERTIFICATE="$(cat tmp/conjur.pem)"`

_Note:_ If you are using v4 Conjur, the Service Broker requires your `CONJUR_POLICY` to have a Host Factory called `CONJUR_POLICY-apps`. For example, if your `CONJUR_POLICY` is `cf`, you can add a Host Factory by updating your policy file to include the following:
```
- !policy
  id: cf
  owner: !group cf-admin-group
  body:
   - !layer cf-apps

   - !host-factory
     id: cf-apps
     layers: [ !layer cf-apps ]
```
If you do not specify a `CONJUR_POLICY` (this is not recommended) in your Service Broker configuration and you are using `CONJUR_VERSION` 4, then you will need to add a Host Factory to the `root` Conjur policy by including:
```
- !layer apps

- !host-factory
  id: apps
  layers: [ !layer apps ]
```


To load these environment variables into the Service Broker's environment, run:
```
cf set-env conjur-service-broker CONJUR_VERSION [value]
cf set-env conjur-service-broker CONJUR_ACCOUNT [value]
cf set-env conjur-service-broker CONJUR_APPLIANCE_URL [value]
cf set-env conjur-service-broker CONJUR_AUTHN_LOGIN [value]
cf set-env conjur-service-broker CONJUR_AUTHN_API_KEY [value]
cf set-env conjur-service-broker CONJUR_POLICY [value]
cf set-env conjur-service-broker CONJUR_SSL_CERTIFICATE [value]
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

The Conjur Buildpack uses [Summon](https://cyberark.github.io/summon/) to load secrets into the environment of CF-deployed applications based on the app's `secrets.yml` file. The Conjur Buildpack is a decorator buildpack, and requires the meta-buildpack to work properly.

Install the [meta-buildpack](https://github.com/cf-platform-eng/meta-buildpack):
```
git clone git@github.com:cf-platform-eng/meta-buildpack
cd meta-buildpack
./build
./upload
```

Install the [Conjur buildpack](https://github.com/conjurinc/cloudfoundry-conjur-buildpack):
```
git clone git@github.com:conjurinc/cloudfoundry-conjur-buildpack
cd cloudfoundry-conjur-buildpack
./upload.sh
```

## Service Broker Usage

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

### Create a `secrets.yml` File

To leverage the Conjur Buildpack so that secret values will automatically be
injected into your application's environment at runtime, a `secrets.yml` file is
required. The `secrets.yml` file gives a mapping of **environment variable name**
to a **location where a secret is stored in Conjur**. For more information about
creating this file, [see the Summon documentation](https://cyberark.github.io/summon/#secrets.yml).

### Bind Your Application to the Conjur Service

Binding your application to the `conjur` service instance automatically gives it
a unique Host identity in Conjur. To bind your application to the `conjur` service
instance, you can either run
```
cf bind-service my-app conjur
```
or you can update the application's deployment manifest to reference the `conjur` service:
```
---
applications:
- name: my-app
  services:
  - conjur
```

### Update Conjur Policy to Privilege Your Application

Once your app has a Host identity in Conjur, you can update Conjur policy to add
entitlements for the app to access secret values in Conjur. The host identity of
the application is stored in the `authn_login` field in the `cyberark-conjur`
credentials in the application's environment, and might look something like
`host/cf/0299a19d-7de4-4e98-89f6-372ac7c0521f` (for example, if your `CONJUR_POLICY`
was set to `cf`).

### Run Your Application

Now that your application is privileged to access the secrets it needs in Conjur,
start or restage the app so that the Conjur Buildpack can inject the secret values
into the running application's environment.

The secrets are now available to be used by the application, but are not visible
when you run `cf env my-app` or if you `cf ssh my-app` and run `printenv`.

## Development

Before getting started, you should install some developer tools. These are not required to deploy the Conjur Service Broker but they will let you develop using a standardized,
expertly configured environment.

1. [git][get-git] to manage source code
2. [Docker][get-docker] to manage dependencies and runtime environments
3. [Docker Compose][get-docker-compose] to orchestrate Docker environments

[get-docker]: https://docs.docker.com/engine/installation
[get-git]: https://git-scm.com/downloads
[get-docker-compose]: https://docs.docker.com/compose/install

To test the usage of the Conjur Service Broker within a CF deployment, you can
follow the demo scripts in the [Cloud Foundry demo repo](https://github.com/conjurinc/cloudfoundry-conjur-demo).

To run the test suite, call `./test.sh` from your local machine - the script will stand up the needed containers and run the full suite of rspec and cucumber tests.

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

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
