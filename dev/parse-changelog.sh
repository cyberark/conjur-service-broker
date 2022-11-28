#!/bin/bash -ex

# shellcheck disable=SC1091
cd "$(dirname "$0")"

docker run --rm \
  -v "$PWD/..:/work" \
  -w "/work" \
  ruby:3.0 bash -ec "
    gem install -N parse_a_changelog
    parse ./CHANGELOG.md
  "

