#!/bin/bash -ex

docker-compose exec -T conjur_5 conjurctl wait -r 30 -p 80
