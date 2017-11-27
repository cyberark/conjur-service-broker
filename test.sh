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

# Stand up containers
# Make sure we keep up to date with gem changes
docker-compose rm -f

docker-compose up -d conjur pg

sleep 10

docker-compose up -d conjur-service-broker
docker-compose exec -T conjur-service-broker ci/test.sh
