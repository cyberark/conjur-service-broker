#!/bin/bash -ex

# Stand up containers
# Make sure we keep up to date with gem changes
docker-compose rm -f

docker-compose up -d conjur pg

sleep 10

docker-compose up -d service-broker

#docker-compose exec service-broker bundle install
#docker-compose exec -d service-broker bash -c "export CONJUR_AUTHN_API_KEY=`cat tmp/api_key` && ./bin/rails s -b 0.0.0.0"

finish() {
  docker-compose down
}
trap finish EXIT

docker-compose exec -T service-broker ci/test.sh
