The Conjur Service Broker makes it easy for you to secure credentials used by applications deployed in Cloud Foundry (CF) with CyberArk Conjur. Using the Conjur Service Broker, your CF applications will automatically assume a Conjur identity on deploy that will enable them to securely access secret values stored in Conjur.

You will need to have an existing Conjur installation in order to use the Conjur Service Broker; for more information about installing Conjur, please visit [conjur.org](http://conjur.org) or check out our [github repository](https://github.com/cyberark/conjur).

The Conjur Service Broker conforms to the [Open Service Broker API](https://www.openservicebrokerapi.org/) standards (version 2.13).

## Getting Started

### Installing the Conjur Buildpack

The Conjur Buildpack uses [Summon](https://cyberark.github.io/summon/) to load secrets into the environment of CF-deployed applications based on the app's `secrets.yml` file. The Conjur Buildpack is a decorator buildpack, and requires the meta-buildpack to work properly.

Before you begin, ensure you are logged into your CF deployment via the CF CLI.

Install the [meta-buildpack repo](https://github.com/cf-platform-eng/meta-buildpack) by running:
```
git clone git@github.com:cf-platform-eng/meta-buildpack
cd meta-buildpack
./build
./upload
```

Install the [Conjur buildpack repo](https://github.com/conjurinc/cloudfoundry-conjur-buildpack) by running:
```
git clone git@github.com:conjurinc/cloudfoundry-conjur-buildpack
cd cloudfoundry-conjur-buildpack
./upload.sh
```

### Installing the Conjur Service Broker

Once you've installed both buildpacks, you can load the Conjur Service Broker into your CF deployment and configure it for use with your external Conjur instance.

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
- `CONJUR_ACCOUNT`: the account name for the Conjur instance you are connecting to
- `CONJUR_APPLIANCE_URL`: the URL of the Conjur appliance instance you are connecting to
- `CONJUR_AUTHN_LOGIN`: the username of a Conjur user with update privilege on all Conjur policies associated with PCF-deployed applications. This will be used to add and remove hosts from the Conjur policy as apps are deployed to or removed from PCF.
- `CONJUR_AUTHN_API_KEY`: the API Key of the Conjur user whose username you have provided in `CONJUR_AUTHN_LOGIN`

To load these environment variables, run:
```
cf set-env conjur-service-broker CONJUR_ACCOUNT [value]
cf set-env conjur-service-broker CONJUR_APPLIANCE_URL [value]
cf set-env conjur-service-broker CONJUR_AUTHN_LOGIN [value]
cf set-env conjur-service-broker CONJUR_AUTHN_API_KEY [value]
```

Once the Service Broker is configured, start the Service Broker application
```
cf start conjur-service-broker
```
and register it with the same Basic Auth credentials specified in your environment variables:
```
APP_URL="http://`cf app conjur-service-broker | grep -E -w 'urls:|routes:' | awk '{print $2}'`"
cf create-service-broker conjur-service-broker "[username value]" "[password value]" $APP_URL --space-scoped
```

Finally, create a service instance under the `community` plan:
```
cf create-service cyberark-conjur community conjur
```

### Service Broker Usage

#### Creating a `secrets.yml` File

To use the Conjur Service Broker with a CF-deployed application, a `secrets.yml` file is required. The `secrets.yml` file gives a mapping of **environment variable name** to a **location where a secret is stored in Conjur**. For more information about creating this file, [see the Summon documentation](https://cyberark.github.io/summon/#secrets.yml).

#### Binding Your Application to the Conjur Service
To bind your application to the Conjur Service Instance, you can either run
```
cf bind-service my-app conjur
```
or you can update the application's deployment manifest to include the Conjur Service:
```
---
applications:
- name: my-app
  services:
  - conjur
```
In order to update the environment to load the secrets using the Conjur Service, you will need to restage the app:
```
cf restage my-app
```

The secrets are now available to be used by the application, but are not visible when you run `cf env my-app` or if you `cf ssh my-app` and run `printenv`.

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
