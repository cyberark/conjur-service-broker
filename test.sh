#!/bin/bash -ex

docker ps

finish() {
  docker-compose down
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
