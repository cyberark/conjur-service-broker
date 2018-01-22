#!/bin/bash -ex

./bin/health-check.rb
./bin/rails s -b 0.0.0.0
