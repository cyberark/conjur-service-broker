#!/bin/bash -ex

docker-compose exec -T conjur_5 conjurctl wait -r 30 -p 80

# load the pcf policy for the non-empty CONJUR_POLICY test
local api_key=$(docker-compose exec -T conjur_5 bash -c 'rails r "puts Role[%Q{cucumber:user:admin}].api_key" 2>/dev/null')
export CONJUR_AUTHN_API_KEY="$api_key"
docker-compose run --rm --entrypoint bash client -c "conjur policy load root /app/ci/policy.yml"
