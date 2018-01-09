## Getting Started

The Conjur Service Broker will allow you to interact with your external Conjur instance
from applications running within a Cloud Foundry (CF) deployment. You will need to have an existing Conjur installation in order to use the Conjur Service Broker; for more information about installing Conjur, please visit [conjur.org](http://conjur.org) or check out our [github repository](https://github.com/cyberark/conjur).

## Installation Instructions

#### Installing the Conjur Buildpack

Before installing the Conjur Service Broker, you will need to load some buildpacks into
your CF installation. The Conjur Buildpack uses [Summon](https://cyberark.github.io/summon/) to load secrets into the environment of CF-deployed applications based on the app's `secrets.yml` file. The Conjur Buildpack is a decorator buildpack, and requires the meta-buildpack to work properly.

Install the `meta-buildpack` by cloning the [meta-buildpack repo](https://github.com/cf-platform-eng/meta-buildpack) and running
(while logged into your CF deployment via the CF CLI):
```
git clone git@github.com:cf-platform-eng/meta-buildpack
cd meta-buildpack
./build
./upload
```

Install the `Conjur buildpack` by cloning the [Conjur buildpack repo](https://github.com/conjurinc/cloudfoundry-conjur-buildpack) and running
(while logged into your CF deployment via the CF CLI):
```
git clone git@github.com:conjurinc/cloudfoundry-conjur-buildpack
cd cloudfoundry-conjur-buildpack
./upload.sh
```

#### Installing the Conjur Service Broker

Once you've installed both buildpacks, you can load the Conjur Service Broker into your CF deployment and configure it for use with your external Conjur
instance. To load the Conjur Service Broker and prepare to use it with your CF-deployed applications, you will:

1. Push the Service Broker application to CF
2. Load the environment to configure the Service Broker
3. Start the Service Broker application, and register it with the same Basic Auth credentials specified in your environment variables
4. Create a service instance under the `community` plan

The following environment variables are required to properly configure your Conjur Service Broker to communicate with your external Conjur instance:
- `CONJUR_ACCOUNT`: the account name for the Conjur instance you are connecting to
- `CONJUR_APPLIANCE_URL`: the URL of the Conjur appliance instance you are connecting to
- `CONJUR_AUTHN_LOGIN`: the username of a Conjur user with update privilege on all Conjur policies associated with PCF-deployed applications. This will be used to add and remove hosts from the Conjur policy as apps are deployed to or removed from PCF.
- `CONJUR_AUTHN_API_KEY`: the API Key of the Conjur user whose username you have provided in the Conjur Login field
- `SECURITY_USER_NAME` and `SECURITY_USER_PASSWORD`: the Basic Auth username and password your Conjur Service Broker should use for authentication


The commands to upload the Conjur Service Broker to your CF deployment are as follows:
```
# Download the repo and push the Service Broker app to CF
git clone git@github.com:conjurinc/conjur-service-broker.git
cd conjur-service-broker
cf push --no-start --random-route

# Set the environment variables to configure the Service Broker app for Basic Authentication
cf set-env conjur-service-broker SECURITY_USER_NAME [value]
cf set-env conjur-service-broker SECURITY_USER_PASSWORD [value]

# Set the environment variables to configure the Service Broker app to communicate with Conjur
cf set-env conjur-service-broker CONJUR_ACCOUNT [value]
cf set-env conjur-service-broker CONJUR_APPLIANCE_URL [value]
cf set-env conjur-service-broker CONJUR_AUTHN_LOGIN [value]
cf set-env conjur-service-broker CONJUR_AUTHN_API_KEY [value]

# Start the Service Broker app
cf start conjur-service-broker

# Register the Service Broker
APP_URL="http://`cf app conjur-service-broker | grep -E -w 'urls:|routes:' | awk '{print $2}'`"
cf create-service-broker conjur-service-broker "[username value]" "[password value]" $APP_URL --space-scoped

# Create a service instance
cf create-service cyberark-conjur community conjur
```

#### Service Broker Usage

To use the Conjur Service Broker with a CF-deployed application, you will update the application to grab its secrets from the environment and include a list of the secrets in the application's `secrets.yml` file. The `secrets.yml` file gives a mapping of environment variable name to a location where a secret is stored in Conjur. For more information about creating this file, [see the Summon documentation](https://cyberark.github.io/summon/#secrets.yml).

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

To test the usage of the Conjur Service Broker within a CF deployment, you can
follow the demo scripts in the [Cloud Foundry demo repo](https://github.com/conjurinc/cloudfoundry-conjur-demo).

Other useful information for development:
- The Conjur Service Broker follows the standard set in v2.12 of the [Open
Service Broker API](https://github.com/openservicebrokerapi/servicebroker/blob/v2.12/spec.md).
- To run the test suite, call `./test.sh` from your local machine - the script
will stand up the needed containers and run the full suite of rspec and cucumber
tests.

#### Contributing

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
