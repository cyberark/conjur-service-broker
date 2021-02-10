# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Removed
- Support for Conjur Enterprise v4 has been removed. We recommend users migrate to
  Dynamic Access Provider v11+ or Conjur OSS v1+.
  [cyberark/conjur-service-broker#203](https://github.com/cyberark/conjur-service-broker/issues/203)

### Fixed
- The service broker Gemfile now specifies the Ruby version so that the service
  broker no longer fails to install when using a version of the Ruby Buildpack
  v1.8.15 or older, due to an incompatibility issue between Ruby and Nokogiri
  versions.
  [cyberark/conjur-service-broker#229](https://github.com/cyberark/conjur-service-broker/issues/229)

## [1.1.4] - 2021-01-11

### Changed
- Previously, our ZIP included our test directories, which increased the size of the service broker. 
  We've introduced a [manifest.txt](https://github.com/cyberark/conjur-service-broker/tree/master/dev/manifest.txt)
  within the `dev` directory which dictates what will be included in the final ZIP used in our
  releases and during installation, and allows us to exclude the test directories and developer
  scripts.
  [cyberark/conjur-service-broker#142](https://github.com/cyberark/conjur-service-broker/issues/142)

### Fixed
- When the value for CONJUR_VERSION is null or empty, we default to `5`. If an invalid
  value is given, we raise an error immediately.
  [cyberark/conjur-service-broker#47](https://github.com/cyberark/conjur-service-broker/issues/47)

### Deprecated
- Support for using the Conjur Service Broker with Conjur Enterprise v4 is now deprecated.
  Support will be removed in the next release.
  [cyberark/conjur-service-broker#191](https://github.com/cyberark/conjur-service-broker/issues/191)

### Security
- Updated `rack` to `v2.2.3` to fix CVE-2020-8184 and CVE-2020-8161.
  [PR cyberark/conjur-service-broker#197](https://github.com/cyberark/conjur-service-broker/pull/197)
- Updated `actionview` to `v5.2.4.4` to fix CVE-2020-15169.
  [cyberark/conjur-service-broker#199](https://github.com/cyberark/conjur-service-broker/pull/199)

## [1.1.3] - 2020-07-17

### Fixed
- Service broker returns 404 when the org / space policy branches do not exist
  as expected with a helpful error message, rather than returning 500.
  [cyberark/conjur-service-broker#192](https://github.com/cyberark/conjur-service-broker/issues/192)
- Service broker health check verifies the `CONJUR_POLICY` exists on the server, if set.
  [cyberark/conjur-service-broker#132](https://github.com/cyberark/conjur-service-broker/issues/132)

## [1.1.2] - 2020-05-15

### Security
- Removed unused development and test gems from main image ([#159](https://github.com/cyberark/conjur-service-broker/issues/159))
- Removed unused development and test gems from ZIP artifact ([#167](https://github.com/cyberark/conjur-service-broker/issues/167))

## [1.1.1] - 2020-01-29
### Added
- Added open source acknowledgements file (NOTICES.txt)
- Added daily build trigger to Jenkinsfile

### Changed
- Bumped dependency versions (rack, puma, loofah, nokogiri, crass, rubyzip)
- Updated license to standard format
- Updated README instructions, including adding Java example
- Updated CI tests to pull cluster info from Conjur using Summon

## [1.1.0] - 2019-05-01
### Added
- Added a health check to verify that the Conjur connection settings will work as
  expected with the Conjur buildpack.
- Provisioning creates a space-level host when loading the org and space policies.
- Added a new bind configuration option `ENABLE_SPACE_IDENTITY` to the service
  broker. When this service broker environment value is set to `true`, then the broker
  will return a space host identity on application bind, rather than create a host
  identity for the app.

### Changed
- Updated actionview (CVE-2019-5418) and railties (CVE-2019-5420) dependency versions

## [1.0.0] - 2019-03-05
### Added
- The service broker will now automatically generate the org and space policy when
  the service is provisioned into a CF space.
- Added service broker environment parameter for `CONJUR_FOLLOWER_URL`. When set, the
  service broker will provide the URL of a follower to an application for retrieving secret
  values.

### Changed
- Updated dependencies and Ruby version of Docker image
- Service broker configuration is updated to explicitly disable instance sharing
- The service broker now adds application Hosts to a Conjur Layer for a Space when the
  bind context contains `context.organization_guid` and `context.space_guid` (CAPI 1.30.0+)

## [0.3.2] - 2018-06-26

### Added
- Health check now verifies that the Service Broker Conjur identity has read privileges on its own resource
- Added cukes to check that Service Broker returns 403 if host does not have proper privileges

### Fixed
- ServiceBinding handles RestClient::NotFound errors on host creation gracefully

### Changed
- Tests now run against Conjur 0.7.0

## [0.3.1] - 2018-06-15
### Added
- The build is updated to run in deployment mode and produce a ZIP file of the project with all dependencies included.

## [0.3.0] - 2018-04-27
### Security
- Updated dependencies to address potential vulnerability in `rails-html-sanitizer` ([more info](https://nvd.nist.gov/vuln/detail/CVE-2018-3741)) and `loofah` ([more info](https://github.com/flavorjones/loofah/issues/144))

### Added
- If the service broker host identity has a `platform` annotation in Conjur, hosts added to policy by the service broker will also include an annotation for the platform.

## [0.2.0] - 2018-02-12
### Added
- Added support for v4 Conjur, including health check that verifies HF existence

## [0.1.0] - 2018-01-24
### Added
- The first tagged version.

[Unreleased]: https://github.com/cyberark/conjur-service-broker/compare/v1.1.4...HEAD
[1.1.4]: https://github.com/cyberark/conjur-service-broker/compare/v1.1.3...v1.1.4
[1.1.3]: https://github.com/cyberark/conjur-service-broker/compare/v1.1.2...v1.1.3
[1.1.2]: https://github.com/cyberark/conjur-service-broker/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/cyberark/conjur-service-broker/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/cyberark/conjur-service-broker/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/cyberark/conjur-service-broker/compare/v0.3.1...v1.0.0
[0.3.1]: https://github.com/cyberark/conjur-service-broker/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/cyberark/conjur-service-broker/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/cyberark/conjur-service-broker/compare/v0.1.0...v0.2.0
