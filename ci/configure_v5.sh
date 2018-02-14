#!/bin/bash -ex

docker-compose exec -T conjur_5 conjurctl wait -r 30 -p 80

# load the pcf policy for the non-empty CONJUR_POLICY test
docker-compose run --rm --entrypoint bash client -c "conjur policy load root /app/ci/policy.yml"
