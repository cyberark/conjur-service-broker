#!/bin/bash -ex

docker-compose down --rmi 'local' --volumes

function finish {
  echo 'Removing test environment'
  echo '---'
  docker-compose down --rmi 'local' --volumes
  rm -f tmp/pids/server*.pid
}
trap finish EXIT

docker-compose up -d conjur pg

docker-compose exec -T conjur conjurctl wait -r 30 -p 80
api_key=$(docker-compose exec -T conjur bash -c 'rails r "puts Role[%Q{cucumber:user:admin}].api_key" 2>/dev/null')
export CONJUR_AUTHN_API_KEY="$api_key"

# load the pcf policy for the non-empty CONJUR_POLICY test
docker-compose run --rm --entrypoint bash client -c "conjur policy load root /app/ci/policy.yml"
export CONJUR_POLICY=pcf

docker-compose up -d conjur-service-broker service-broker-bad-url service-broker-bad-key service-broker-alt-policy
docker-compose run tests ci/test.sh
