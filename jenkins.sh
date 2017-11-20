#!/bin/bash -e

docker-compose rm -fs
docker-compose up -d
docker-compose exec service-broker bundle install
docker-compose exec service-broker bash -c "export CONJUR_AUTHN_API_KEY=`cat tmp/api_key` && ./bin/rails s -b 0.0.0.0"