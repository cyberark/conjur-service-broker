#!/bin/bash -ex

finish() {
  docker-compose down
}
trap finish EXIT

# Stand up containers
# Make sure we keep up to date with gem changes
docker-compose rm -f

docker-compose up -d conjur pg

sleep 10

docker-compose up -d conjur-service-broker
docker-compose exec -T conjur-service-broker ci/test.sh
