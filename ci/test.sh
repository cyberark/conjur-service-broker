#!/bin/bash -x

rspec --format RspecJunitFormatter --out spec/reports/test.xml --format progress

# TODO: work rails s into cucumber bootstrap process.
export AUTH_USERNAME="TEST_USER_NAME"
export AUTH_PASSWORD="TEST_USER_PASSWORD"
rails s -p 3000 -d
cucumber --format junit --out features/reports  --format pretty

# exit 0 so failing tests will mark the build unstable
exit 0
