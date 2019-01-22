#!/bin/bash -ex

TAG="$(< VERSION)-$(git rev-parse --short HEAD)"

echo "Getting updated images"
docker-compose pull conjur_4 conjur_5

echo "Building conjur-service-broker Docker image"
docker-compose build conjur-service-broker
docker-compose build tests

echo "Tagging conjur-service-broker:$TAG"
docker tag conjur-service-broker "conjur-service-broker:$TAG"

echo "Running deployment build to install dependencies locally"
echo "Creating project ZIP file"
docker-compose run \
  --rm \
  conjur-service-broker \
  bash -c "
    bundle pack --all
    zip -r cyberark-conjur-service-broker_$(cat VERSION).zip ./*
  "
