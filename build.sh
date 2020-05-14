#!/bin/bash -ex

TAG="$(< VERSION)-$(git rev-parse --short HEAD)"

echo "Getting updated images (this may take a few minutes)..."
docker-compose pull -q conjur_4 conjur_5

echo "Building Buildpack Health Check executable"
rm -rf bin/buildpack-health-check
docker-compose -f buildpack-health-check/docker-compose.yml build
docker-compose -f buildpack-health-check/docker-compose.yml \
  run --rm buildpack-health-check-builder

echo "Building conjur-service-broker image"
docker build -t "conjur-service-broker:$TAG" \
  -t "conjur-service-broker:latest" \
  .

echo "Building conjur-service-broker-test image"
docker build -t "conjur-service-broker-test:latest" \
  -f Dockerfile.test \
  .

echo "Running deployment build to install dependencies locally"
echo "Creating project ZIP file"
docker run --rm \
  -v "$(pwd):/output" \
  conjur-service-broker \
  bash -ec "
    echo 'Bundling dependencies...'
    bundle package --all --no-install

    echo 'Removing the old zip...'
    rm -rf /output/cyberark-conjur-service-broker_$(cat VERSION).zip

    echo 'Zipping everything up...'
    zip -r \
      /output/cyberark-conjur-service-broker_$(cat VERSION).zip ./* \
      -x vendor/bundle
  "
