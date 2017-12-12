#!/bin/bash -ex

# TODO - The commented arguments are throwing an exeception unreleated to the
# success of the RSpec test.  We need to get this resolved and export the
# resulting XML file to the `spec/reports` folder for Jenkins to pickup.
rspec # --format RspecJunitFormatter --out spec/reports/test.xml

cucumber --format junit --out features/reports  --format pretty --backtrace --verbose
