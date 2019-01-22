#!/bin/bash -ex

# TODO - The commented arguments are throwing an exeception unreleated to the
# success of the RSpec test.  We need to get this resolved and export the
# resulting XML file to the `spec/reports` folder for Jenkins to pickup.
rspec # --format RspecJunitFormatter --out spec/reports/test.xml

# Skip the integration tests if the Summon variables are not present
if [ -z "$CF_API_ENDPOINT" ]; then
    INTEGRATION_TAG="--tags ~@integration"
else
    # Make sure all of the environment are present for the integration tests
    : ${PCF_CONJUR_ACCOUNT?"Need to set PCF_CONJUR_ACCOUNT"}
    : ${PCF_CONJUR_APPLIANCE_URL?"Need to set PCF_CONJUR_APPLIANCE_URL"}
    : ${PCF_CONJUR_USERNAME?"Need to set PCF_CONJUR_USERNAME"}
    : ${PCF_CONJUR_API_KEY?"Need to set STATE"}
    : ${CF_CI_USER?"Need to set CF_CI_USER"}
    : ${CF_CI_PASSWORD?"Need to set CF_CI_PASSWORD"}
fi  

cucumber --format junit \
  --out features/reports \
  $INTEGRATION_TAG \
  --format pretty \
  --backtrace \
  --verbose
