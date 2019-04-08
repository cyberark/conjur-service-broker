#!/bin/bash -ex

function finish {
  echo 'Removing test environment'
  echo '---'
  docker-compose down --rmi 'local' --volumes
  rm -f tmp/pids/server*.pid
}
trap finish EXIT

SERVICE_BROKERS='service-broker-bad-url service-broker-bad-key service-broker-follower-url'

function main() {
  startConjur
  runTests5
  cleanUpServiceBrokers
  runTests4
}

function startConjur() {
  echo "Starting Conjur environment"
  echo "---"
  docker-compose up -d pg conjur_4 conjur_5
}

function runTests() {
  docker-compose up -d $SERVICE_BROKERS

  export CONJUR_POLICY=cf

  if [[ $1 -eq 4 ]]
  then
    export CONJUR_AUTHN_API_KEY="$(docker-compose exec -T conjur_4 su conjur -c "conjur-plugin-service authn env RAILS_ENV=appliance rails r \"puts User['host/cf-service-broker'].api_key\" 2>/dev/null")"
  else
    export CONJUR_AUTHN_API_KEY="$(docker-compose exec -T conjur_5 bash -c 'rails r "puts Role[%Q{cucumber:host:cf-service-broker}].api_key" 2>/dev/null')"
  fi

  docker-compose up -d conjur-service-broker service-broker-alt-policy

  if [[ $1 -eq 4 ]]
  then
    bad_host_api_key="$(docker-compose exec -T conjur_4 su conjur -c "conjur-plugin-service authn env RAILS_ENV=appliance rails r \"puts User['host/bad-service-broker'].api_key\" 2>/dev/null")"
  else
    bad_host_api_key="$(docker-compose exec -T conjur_5 bash -c 'rails r "puts Role[%Q{cucumber:host:bad-service-broker}].api_key" 2>/dev/null')"
  fi

  export CONJUR_AUTHN_API_KEY=$bad_host_api_key

  docker-compose up -d service-broker-bad-host

  echo "Running tests"
  echo "---"

  # Set BAD_HOST_API_KEY to test an error case in bin/health-check.rb
  docker-compose run -e CONJUR_AUTHN_API_KEY=$admin_api_key -e BAD_HOST_API_KEY=$bad_host_api_key tests ci/test.sh
}

function runTests5() {
  echo "Waiting for Conjur v5 to come up, and configuring it..."
  ./ci/configure_v5.sh

  export CONJUR_VERSION=5
  export CONJUR_APPLIANCE_URL=http://conjur_5
  export CONJUR_FOLLOWER_URL=http://conjur_5-follower
  export CONJUR_SSL_CERTIFICATE=""

  admin_api_key=$(docker-compose exec -T conjur_5 bash -c 'rails r "puts Role[%Q{cucumber:user:admin}].api_key" 2>/dev/null')
  export CONJUR_AUTHN_API_KEY="$admin_api_key"

  remote_appliance_host=$(echo $PCF_CONJUR_APPLIANCE_URL | sed 's~http[s]*://~~g')
  
  export PCF_CONJUR_SSL_CERT=$(openssl s_client -showcerts \
    -connect $remote_appliance_host:443 </dev/null 2>/dev/null \
    | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p')

  runTests 5
}

function cleanUpServiceBrokers() {
  echo "Cleaning up running service brokers..."
  docker-compose rm -f -s -v $SERVICE_BROKERS service-broker-alt-policy
}

function runTests4() {
  echo "Waiting for Conjur v4 to come up, and configuring it..."
  ./ci/configure_v4.sh

  export CONJUR_VERSION=4
  export CONJUR_APPLIANCE_URL=https://conjur_4/api
  export CONJUR_FOLLOWER_URL=https://conjur_4-follower/api
  export CONJUR_SSL_CERTIFICATE="$(cat tmp/conjur.pem)"

  admin_api_key=$(docker-compose exec -T conjur_4 su conjur -c "conjur-plugin-service authn env RAILS_ENV=appliance rails r \"puts User['admin'].api_key\" 2>/dev/null")
  export CONJUR_AUTHN_API_KEY="$admin_api_key"

  runTests 4
}

main
