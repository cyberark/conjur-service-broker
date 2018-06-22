# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.1] - 2018-06-15

### Added
The build is updated to run in deployment mode and produce a ZIP file of the project with all dependencies included.

## [0.3.0] - 2018-04-27

### Security
Updated dependencies to address potential vulnerability in `rails-html-sanitizer` ([more info](https://nvd.nist.gov/vuln/detail/CVE-2018-3741)) and `loofah` ([more info](https://github.com/flavorjones/loofah/issues/144))

### Added
If the service broker host identity has a `platform` annotation in Conjur, hosts added to policy by the service broker will also include an annotation for the platform.

## [0.2.0] - 2018-02-12

### Added
Added support for v4 Conjur, including health check that verifies HF existence

## [0.1.0] - 2018-01-24

The first tagged version.

[Unreleased]: https://github.com/cyberark/conjur-service-broker/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/cyberark/conjur-service-broker/compare/v0.1.0...v0.2.0
[0.3.0]: https://github.com/cyberark/conjur-service-broker/compare/v0.2.0...v0.3.0
[0.3.1]: https://github.com/cyberark/conjur-service-broker/compare/v0.3.0...v0.3.1
