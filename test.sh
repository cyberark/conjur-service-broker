#!/bin/bash -ex

docker ps

docker-compose down --rmi 'local' --volumes

function finish {
  echo 'Removing test environment'
  echo '---'
  docker-compose down --rmi 'local' --volumes
}
trap finish EXIT

export COMPOSE_PROJECT_NAME=conjurdev


docker-compose build conjur-service-broker
docker-compose up -d conjur
sleep 10
docker-compose run conjur-service-broker ci/test.sh
