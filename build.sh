#!/bin/bash -ex

TAG="$(< VERSION)-$(git rev-parse --short HEAD)"

echo "Getting updated images"
docker-compose pull conjur_4 conjur_5

echo "Building conjur-service-broker Docker image"
docker-compose build conjur-service-broker

echo "Tagging conjur-service-broker:$TAG"
docker tag conjur-service-broker "conjur-service-broker:$TAG"
