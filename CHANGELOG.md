# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.8] - 2023-03-14
### Changed
- Upgrade supported Ruby version to 3.1.x. Resolves CVE-2021-33621, CVE-2020-36327 and CVE-2021-43809
  [cyberark/conjur-service-broker#306](https://github.com/cyberark/conjur-service-broker/pull/306)

### Security
- Update rack in Gemfile.lock and tests/integration/test-app/Gemfile.lock to 2.2.6.3
  for CVE-2023-27630 (not vulnerable)
  [cyberark/conjur-service-broker#320](https://github.com/cyberark/conjur-service-broker/pull/320)
- Update activesupport in Gemfile.lock to 6.1.7.2 for CVE-2023-22796 (not vulnerable)
  [cyberark/conjur-service-broker#312](https://github.com/cyberark/conjur-service-broker/pull/312)
- Update activesupport in tests/integration/test-app/Gemfile.lock to 7.0.4.1
  for CVE-2023-22796 (not vulnerable) 
  [cyberark/conjur-service-broker#307](https://github.com/cyberark/conjur-service-broker/pull/307)
- Update conjur-api-go to v0.10.2 to udpate indirect dependency gopkg.in/yaml.v2
  [cyberark/conjur-service-broker#305](https://github.com/cyberark/conjur-service-broker/pull/305)
- Update loofah to 2.19.1 for CVE-2022-23514, CVE-2022-23515 and CVE-2022-23516 (all Not Vulnerable)
  and rails-html-sanitizr to 1.4.4 for CVE-2022-23517, CVE-2022-23518, CVE-2022-23519, and CVE-2022-23520 (Not vulnerable)
  [cyberark/conjur-service-broker#304](https://github.com/cyberark/conjur-service-broker/pull/304)
- Upgrade nokogiri to 1.13.10 to resolve CVE-2022-23476
  [cyberark/conjur-service-broker#302](https://github.com/cyberark/conjur-service-broker/pull/302)
- Upgrade sinatra to 2.2.3 in tests/integration/test-app
  [cyberark/conjur-service-broker#301](https://github.com/cyberark/conjur-service-broker/pull/301)

## [1.2.7] - 2022-11-27
### Security
- Upgrade nokogiri to v1.3.9 to resolve GHSA-2qc6-mcvw-92cw
  [cyberark/conjur-service-broker#296](https://github.com/cyberark/conjur-service-broker/pull/296)
- Upgrade cucumber (2.99.0 -> 7.1.0) and aruba (1.1.2 -> 2.0.0)
  to resolve medium severity security issue on Snyk
  [cyberark/conjur-service-broker#294](https://github.com/cyberark/conjur-service-broker/pull/294)

## [1.2.6] - 2022-08-16
### Security
- Updated tzinfo to 1.2.10 in Gemfile.lock and test/integration/test-app/Gemfile.lock to 
  resolve CVE-2022-31163
  [cyberark/conjur-service-broker#289](https://github.com/cyberark/conjur-service-broker/pull/289)
- Updated rails-html-sanitizer to 1.4.3 to resolve CVE-2022-32209
  [cyberark/conjur-service-broker#288](https://github.com/cyberark/conjur-service-broker/pull/288)

## [1.2.5] - 2022-06-16
### Changed
- Upgrade conjur-api-go to v0.10.1 and rack to 2.2.3.1
  [cyberark/conjur-service-broker#285](https://github.com/cyberark/conjur-service-broker/pull/285)

### Security
- Upgrade nokogiri to 1.13.6 to resolve un-numbered libxml CVEs
  [cyberark/conjur-service-broker#280](https://github.com/cyberark/conjur-service-broker/pull/280)
- Upgrade rack to 2.2.3.1 to resolves CVE-2022-30122 and CVE-2022-30123
  [cyberark/conjur-service-broker#283](https://github.com/cyberark/conjur-service-broker/pull/283)

## [1.2.4] - 2022-05-05
### Security
- Upgrade nokogiri to 1.13.4 to resolve CVE-2022-24836, CVE-2018-25032, 
  CVE-2022-24839, and CVE-2022-23437 (not vulnerable to all)
  [cyberark/conjur-service-broker#273](https://github.com/cyberark/conjur-service-broker/pull/273)
- Upgraded puma to 5.6.4 to resolve CVE-2022-24790 
  [cyberark/conjur-service-broker#271](https://github.com/cyberark/conjur-service-broker/pull/271)
- Upgraded rails components to 5.2.6.2 and puma to 5.6.2 to resolve CVE-2022-23633 and 
  CVE-2022-23634 [cyberark/conjur-service-broker#270](https://github.com/cyberark/conjur-service-broker/pull/270)
- Updated puma to 5.5.1
  [cyberark/conjur-service-broker#267](https://github.com/cyberark/conjur-service-broker/pull/267)
- Update rails components to 5.2.7.1 to resolve CVE-2022-22577 and CVE-2022-27777
  [cyberark/conjur-service-broker#274](https://github.com/cyberark/conjur-service-broker/pull/274)

### Fixed
- Unpin the Ruby Buildpack in the service broker's `manifest.yml` and update the pinned
  Ruby version in the service broker's `Gemfile` to `~> 2.7`. This captures the idea that
  the service broker works for all 2.x Ruby versions from 2.7 and up, anything less has reached end of life.
  [cyberark/conjur-service-broker#266](https://github.com/cyberark/conjur-service-broker/pull/266)

## [1.2.3] - 2021-12-31
### Changed
- Updated to go 1.17 and conjur-api-go 0.8.1
  [cyberark/conjur-service-broker#263](https://github.com/cyberark/conjur-service-broker/pull/263)

## [1.2.2] - 2021-11-03
### Security
- Updated Nokogiri to 1.12.5-x86_64-darwin to resolve 
  [CVE-2021-41098](https://github.com/advisories/GHSA-2rr5-8q37-2w7h)
  [cyberark/conjur-service-broker#257](https://github.com/cyberark/conjur-service-broker/pull/257)

## [1.2.1] - 2021-08-02
### Fixed
- The service broker's `./manifest.yml` now explicitly specifies a pinned version of the Ruby Buildpack,
  [ruby-buildpack.git#v1.8.37](https://github.com/cloudfoundry/ruby-buildpack/releases/tag/v1.8.37),
  to ensure the pinned Ruby version in the Gemfile is available when the the service broker is deployed
  onto TAS foundation.
  [cyberark/conjur-service-broker#254](https://github.com/cyberark/conjur-service-broker/issues/254)

## [1.2.0] - 2021-06-09
### Added
- Service Broker API spec 2.15 and above provide `organization_name` and `space_name`.
  If these are available, they are added as annotations on the organization and space policies
  that are created in Conjur. Note that this requires Conjur Open Source v1.3.7+ and Conjur
  Enterprise (formerly Dynamic Access Provider) v11.3.0+; prior to these versions, Conjur
  did not support adding annotations to policy resources.
  [cyberark/conjur-service-broker#238](https://github.com/cyberark/conjur-service-broker/issues/238)

### Security
- Updated addressable to 2.8.0 to resolve GHSA-jxhc-q857-3j6g
  [cyberark/conjur-service-broker#251](https://github.com/cyberark/conjur-service-broker/pull/251)
- Updated puma to 5.3.1 to resolve GHSA-q28m-8xjw-8vr5
  [cyberark/conjur-service-broker#246](https://github.com/cyberark/conjur-service-broker/issues/246)
- Updated nokogiri to 1.11.5 to resolve GHSA-7rrm-v45f-jp64 
  [cyberark/conjur-service-broker#246](https://github.com/cyberark/conjur-service-broker/issues/246)
- Updated rails packages (activesupport, railties, actionview) to 5.2.4.6 to resolve CVE-2021-22885
  [cyberark/conjur-service-broker#241](https://github.com/cyberark/conjur-service-broker/issues/241)

## [1.1.5] - 2021-03-01
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

[Unreleased]: https://github.com/cyberark/conjur-service-broker/compare/v1.2.8...HEAD
[1.2.8]: https://github.com/cyberark/conjur-service-broker/compare/v1.2.7...v1.2.8
[1.2.7]: https://github.com/cyberark/conjur-service-broker/compare/v1.2.6...v1.2.7
[1.2.6]: https://github.com/cyberark/conjur-service-broker/compare/v1.2.5...v1.2.6
[1.2.5]: https://github.com/cyberark/conjur-service-broker/compare/v1.2.4...v1.2.5
[1.2.4]: https://github.com/cyberark/conjur-service-broker/compare/v1.2.3...v1.2.4
[1.2.3]: https://github.com/cyberark/conjur-service-broker/compare/v1.2.2...v1.2.3
[1.2.2]: https://github.com/cyberark/conjur-service-broker/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/cyberark/conjur-service-broker/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/cyberark/conjur-service-broker/compare/v1.1.5...v1.2.0
[1.1.5]: https://github.com/cyberark/conjur-service-broker/compare/v1.1.4...v1.1.5
[1.1.4]: https://github.com/cyberark/conjur-service-broker/compare/v1.1.3...v1.1.4
[1.1.3]: https://github.com/cyberark/conjur-service-broker/compare/v1.1.2...v1.1.3
[1.1.2]: https://github.com/cyberark/conjur-service-broker/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/cyberark/conjur-service-broker/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/cyberark/conjur-service-broker/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/cyberark/conjur-service-broker/compare/v0.3.1...v1.0.0
[0.3.1]: https://github.com/cyberark/conjur-service-broker/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/cyberark/conjur-service-broker/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/cyberark/conjur-service-broker/compare/v0.1.0...v0.2.0
