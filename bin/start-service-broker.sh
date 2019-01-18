#!/bin/bash -ex

# Remove stale rails pid file, if it exists
if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

./bin/health-check.rb
./bin/rails s -b 0.0.0.0
