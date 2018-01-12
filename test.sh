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

docker-compose exec -T conjur conjurctl wait -r 25 -p 80
api_key=$(docker-compose exec -T conjur bash -c 'rails r "puts Role[%Q{cucumber:user:admin}].api_key" 2>/dev/null')
export CONJUR_AUTHN_API_KEY="$api_key"

docker-compose up -d conjur-service-broker service-broker-bad-url service-broker-bad-key
docker-compose run tests ci/test.sh
