#!/bin/bash -ex

rspec # --format RspecJunitFormatter --out spec/reports/test.xml --format progress

cucumber --format junit --out features/reports  --format pretty --backtrace --verbose
