#!/bin/bash -e

printf "Waiting for Conjur to be ready... "
while [[ ! $(curl -o /dev/null -s -w '%{http_code}\n' conjur) == 200 ]]
do
  echo "."
  sleep 1
done
echo "Done."

