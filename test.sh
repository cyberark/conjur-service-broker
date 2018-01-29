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
#  runTests4
}

function startConjur() {
  echo "Starting Conjur environment"
  echo "---"
  docker-compose up -d pg conjur_4 conjur_5
}

function runTests5() {
  echo "Waiting for Conjur v5 to come up, and configuring it..."
  ./ci/configure_v5.sh

  api_key=$(docker-compose exec -T conjur_5 bash -c 'rails r "puts Role[%Q{cucumber:user:admin}].api_key" 2>/dev/null')
  export CONJUR_AUTHN_API_KEY="$api_key"

  # load the pcf policy for the non-empty CONJUR_POLICY test
  docker-compose run --rm --entrypoint bash client -c "conjur policy load root /app/ci/policy.yml"
  export CONJUR_POLICY=pcf

  docker-compose up -d conjur-service-broker service-broker-bad-url service-broker-bad-key service-broker-alt-policy
  docker-compose run tests ci/test.sh
}

function runTests4() {
  echo "running the v4 tests"
}

main
