# Contributing

For general contribution and community guidelines, please see the [community repo](https://github.com/cyberark/community).

## Development

Before getting started, you should install some developer tools. These are not required to deploy the Conjur Service Broker but they will let you develop using a standardized,
expertly configured environment.

1. [git][get-git] to manage source code
2. [Docker][get-docker] to manage dependencies and runtime environments
3. [Docker Compose][get-docker-compose] to orchestrate Docker environments

[get-docker]: https://docs.docker.com/engine/installation
[get-git]: https://git-scm.com/downloads
[get-docker-compose]: https://docs.docker.com/compose/install

To test the usage of the Conjur Service Broker within a CF deployment, you can
follow the demo scripts in the [Cloud Foundry demo repo](https://github.com/conjurinc/cloudfoundry-conjur-demo).

To run the test suite, call `./test.sh` from your local machine - the script will stand up the needed containers and run the full suite of rspec and cucumber tests.

## Testing

### Running Tests

To run the service broker unit tests run:
```sh-session
$ ./test.sh
```

### Integration Testing

The Conjur Service Broker integration tests have external dependencies to run successfully:

* A Cloud Foundry foundation (version 2.4)
* A Conjur instance accessible by the test runner and by the Cloud Foundry instance above
    > The configuration and policy for this conjur instance are defined in `./ci/integration/conjur`

The connection information and credentials for these service are provided by Summon to the test runner.

See [secrets.yml](./secrets.yml) for the variables required to run the tests.

Once Summon is configured when the connection information, the integration tests may be executed byt running:
```sh-session
$ summon ./test.sh
```

## Releases

1. Based on the unreleased content, determine the new version number and update
   the [VERSION](VERSION) file. This project uses [semantic versioning](https://semver.org/).
1. Ensure the [changelog](CHANGELOG.md) is up to date with the changes included in the release.
1. Ensure the [open source acknowledgements](NOTICES.txt) are up to date with the dependencies,
   and update the file if there have been any new or changed dependencies since the last release.
   See [Tracking Dependencies](#tracking-dependencies) for more info on how to check for dependency
   changes and update the acknowledgements file.
1. Commit these changes - `Bump version to x.y.z` is an acceptable commit message.
1. Once your changes have been reviewed and merged into master, tag the version
   using `git tag -s v0.1.1`. Note this requires you to be  able to sign releases.
   Consult the [github documentation on signing commits](https://help.github.com/articles/signing-commits-with-gpg/)
   on how to set this up. `vx.y.z` is an acceptable tag message.
1. Push the tag: `git push vx.y.z` (or `git push origin vx.y.z` if you are working
   from your local machine).

When releasing a new version of the Service Broker, you will need to include a
ZIP file with the release of the repository with all dependencies. Running the
`./build.sh` script will run `bundle pack --all`, which creates a
`vendor/cache/` directory with the project dependencies. It will also produce a ZIP
file of the project which includes this directory. The ZIP file should be uploaded
to the release in GitHub; it will be used to build the PCF tile.

### Tracking Dependencies

You can use the `license_finder` gem to keep track of dependency changes. The current
state is stored in the [dependency decisions file][./doc/dependency_decisions.yml].

Before tagging a new version, run the `license_finder` tool with no arguments to
see all the updated dependencies:
```
bundle exec license_finder
```

For each unapproved dependency, update the [acknowledgements file](./NOTICES.txt)
with the updated version and copyright information, then approve it:
```
bundle exec license_finder approval add [dependency] --version=[dependency_version]
```

Notes:
* The tool does no validation on approvals, so be sure you're entering the right
  name and version. Check the action items again after you've added an approval
  to ensure it's now gone.
* The tool allows you to omit a version number, and that will approve all versions
  of that dependency. In that case, the tool will no longer track version changes
  and the acknowledgements will become out of date on the next update. **Do not do this**.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
