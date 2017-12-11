#!/bin/bash -ex

docker ps

docker-compose down --rmi 'local' --volumes

function finish {
  echo 'Removing test environment'
  echo '---'
  docker-compose down --rmi 'local' --volumes
  rm -f tmp/pids/server.pid
}
trap finish EXIT

export COMPOSE_PROJECT_NAME=conjurdev


docker-compose build conjur-service-broker
docker-compose up -d
sleep 10
docker-compose run tests ci/test.sh
