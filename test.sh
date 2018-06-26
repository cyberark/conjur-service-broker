#!/bin/bash -ex

function finish {
  echo 'Removing test environment'
  echo '---'
  docker-compose down --rmi 'local' --volumes
  rm -f tmp/pids/server*.pid
}
trap finish EXIT

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
  docker-compose up -d conjur-service-broker service-broker-bad-url service-broker-bad-key

  export CONJUR_POLICY=cf
  if [[ $1 -eq 4 ]]
  then
    export CONJUR_AUTHN_API_KEY="$(docker-compose exec -T conjur_4 su conjur -c "conjur-plugin-service authn env RAILS_ENV=appliance rails r \"puts User['host/cf-service-broker'].api_key\" 2>/dev/null")"
  else
    export CONJUR_AUTHN_API_KEY="$(docker-compose exec -T conjur_5 bash -c 'rails r "puts Role[%Q{cucumber:host:cf-service-broker}].api_key" 2>/dev/null')"
  fi

  docker-compose up -d service-broker-alt-policy

  if [[ $1 -eq 4 ]]
  then
    export CONJUR_AUTHN_API_KEY="$(docker-compose exec -T conjur_4 su conjur -c "conjur-plugin-service authn env RAILS_ENV=appliance rails r \"puts User['host/bad-service-broker'].api_key\" 2>/dev/null")"
  else
    export CONJUR_AUTHN_API_KEY="$(docker-compose exec -T conjur_5 bash -c 'rails r "puts Role[%Q{cucumber:host:bad-service-broker}].api_key" 2>/dev/null')"
  fi

  docker-compose up -d service-broker-bad-host

  echo "Running tests"
  echo "---"
  docker-compose run -e CONJUR_AUTHN_API_KEY=$api_key tests ci/test.sh
}

function runTests5() {
  echo "Waiting for Conjur v5 to come up, and configuring it..."
  ./ci/configure_v5.sh

  export CONJUR_VERSION=5
  export CONJUR_APPLIANCE_URL=http://conjur_5
  export CONJUR_SSL_CERTIFICATE=""

  api_key=$(docker-compose exec -T conjur_5 bash -c 'rails r "puts Role[%Q{cucumber:user:admin}].api_key" 2>/dev/null')
  export CONJUR_AUTHN_API_KEY="$api_key"

  runTests 5
}

function cleanUpServiceBrokers() {
  echo "Cleaning up running service brokers..."
  docker-compose rm -f -s -v conjur-service-broker service-broker-bad-url service-broker-bad-key service-broker-alt-policy
}

function runTests4() {
  echo "Waiting for Conjur v4 to come up, and configuring it..."
  ./ci/configure_v4.sh

  export CONJUR_VERSION=4
  export CONJUR_APPLIANCE_URL=https://conjur_4/api
  export CONJUR_SSL_CERTIFICATE="$(cat tmp/conjur.pem)"

  api_key=$(docker-compose exec -T conjur_4 su conjur -c "conjur-plugin-service authn env RAILS_ENV=appliance rails r \"puts User['admin'].api_key\" 2>/dev/null")
  export CONJUR_AUTHN_API_KEY="$api_key"

  runTests 4
}

main
