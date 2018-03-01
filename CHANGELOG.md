# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
If the service broker host identity has a `platform` annotation in Conjur, hosts added to policy by the service broker will also include an annotation for the platform.

## [0.2.0] - 2018-02-12

### Added
Added support for v4 Conjur, including health check that verifies HF existence

## [0.1.0] - 2018-01-24

The first tagged version.

[Unreleased]: https://github.com/conjurinc/conjur-service-broker/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/conjurinc/conjur-service-broker/compare/v0.1.0...v0.2.0
