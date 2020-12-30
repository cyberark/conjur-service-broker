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

## Development Environment

The `dev/start` script sets up a development environment that allows you
to selectively run unit and integration tests interactively against local,
containerized instances of the Conjur Service Broker and Conjur.

In this development environment, the Service Broker source code is
volume mounted in the Service Broker instances, so that any changes that
you make to Service Broker code is immediately reflected in the
Service Broker instances. In other words, there is no need to rebuild
and restart containers when code changes are made.

To start the Service Broker development environment, first build the base
and development images, and then run the `dev/start` script to set up
the development environment:

```sh-session
./dev/build
./dev/build_dev
./dev/start
```

After starting up Service Broker and Conjur container instances, the scripts 
leave you in an interactive shell that prompts you to select one of the
following:

```
   1) Run rspec unit tests
   2) Run integration (non-E2E) Cucumber tests
   3) Select from a list of Cucumber features to test
   4) Select from a list of Cucumber scenarios to test
   5) Run a bash shell in test container
   6) Exit and clean up development environment
```

When you choose options 3) or 4), you will be prompted to select from
a list of Cucumber features or scenarios, respectively. This allows you
to run focused tests as you are iterating through code changes.

Option 6) will let you exit the test container, and all Service Broker
and Conjur container instances will be cleaned up.

## Non-Interactive Testing

### Running Unit Tests

To run the Conjur Service Broker unit tests, first build the base image
and artifacts::

```sh-session
./dev/build
```

Then, run the tests with the following command:
```sh-session
./dev/test_unit
```

### Running Local Integration Tests

The [dev/test_integration](./dev/test_integration) script provides a full suite of integration tests
for testing Service Broker functionality against Conjur. The tests use Docker
Compose to spin up local instances of Conjur and Service Brokers, so the
tests can be run locally.

To run the Service Broker local integration tests, first build the base image
and artifacts:

```sh-session
./dev/build
```

Then, run the tests with the following command:

```sh-session
./dev/test_integration
```

_Note: The integration tests rely on having built `conjur-service-broker`
and `conjur-service-broker-test`. If you make changes to your local repository
and would like to see those changes reflected in the test containers, either
re-run `./dev/build` or run `docker-compose build <service_name>` to rebuild
the source image(s) before running the tests._

### End-to-End (E2E) Integration Testing

The Conjur Service Broker End-to-End integration tests have external dependencies to run successfully:

* A Cloud Foundry foundation (version 2.4)
* A Conjur instance accessible by the test runner and by the Cloud Foundry instance above
    > The configuration and policy for this conjur instance are defined in `./tests/integration/conjur`

The connection information and credentials for these service are provided by Summon to the test runner.

See [dev/secrets.yml](./dev/secrets.yml) for the variables required to run the tests.

Once Summon is configured with the connection information, the end-to-end
tests may be executed by first building the base images and artifacts:

```sh-session
./dev/build
```

And then running the following:

```sh-session
cd dev
summon ./test_e2e
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
ZIP file with the release of the repository with all dependencies. 

1. Verify that `dev/manifest.txt` includes all relevant top-level directories and files.
   These will be copied into a temporary `pkg` directory used when zipping, to avoid
   including unnecessary files in our ZIP.
1. Run the `./dev/build` script, which will run `bundle pack --all`, which creates a
   `vendor/cache/` directory with the project dependencies. It will also produce a ZIP
   file of the project which includes this directory. 
1. Attach the ZIP file to the release draft; it will be used to build the VMWare Tanzu tile.

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
