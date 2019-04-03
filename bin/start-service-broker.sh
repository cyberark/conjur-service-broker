#!/bin/bash -ex

# Remove stale rails pid file, if it exists
if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

# Health check for service broker connection to Conjur
./bin/health-check.rb

# Health check for buildpack connection to Conjur
./bin/buildpack-health-check

./bin/rails s -b 0.0.0.0
