# Contributing

For general contribution and community guidelines, please see the [community repo](https://github.com/cyberark/community).

## Development

Before getting started, you should install some developer tools.
These are not required to deploy the Conjur Service Broker but
they will let you develop using a standardized, expertly configured
environment.

1. [git][get-git] to manage source code
2. [Docker][get-docker] to manage dependencies and runtime environments

[get-docker]: https://docs.docker.com/engine/installation
[get-git]: https://git-scm.com/downloads

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

The [dev/test_integration](./dev/test_integration) script provides a full
suite of integration tests for testing Service Broker functionality
against Conjur. The tests use Docker Compose to spin up local instances
of Conjur and Service Brokers, so the tests can be run locally.

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
re-run `./dev/build` or run `docker compose build <service_name>` to rebuild
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

#### Running End-to-End (E2E) Tests With a Custom TAS Instance

To run the end-to-end tests with a custom TAS instance, such as one created via the VMWare ISV Dashboard, follow these steps:

- Download the Hammer File from the VMWare ISV Dashboard and place it in the root of the repository, named `hammerfile.json`.
- In `./dev/test_e2e`, comment out the line `bl_retry_constant 5 30 ipmanager add "${compute_ip}"`
  and replace it with `echo "Add IP $compute_ip to IPManager"`. When the command runs, copy the printed IP
  and add it manually to IPManager (<https://ipmanager.itp.conjur.net/addip>)
- Comment out the `IPMANAGER_TOKEN` variable in `./dev/secrets.yml`.
- Run `summon ./dev/test_e2e`

## Updating Dependencies

### Finding and Fixing Security Vulnerabilities

To detect if there are any known security vulnerabilities in gem
dependencies, run the following:

   ```
   docker compose run tests bundle audit
   ```

If any known security vulnerabilities are discovered, you will see
the following in the command output:

   ```
   Vulnerabilities found!
   ```

If there are known upgrade solutions for eliminating the vulnerability,
then the command output will also include ranges of versions to which
the gem can be updated to resolve the vulnerability.

Knowing the acceptable range of gem versions, you will first want to
check the `Gemfile` for possible constraints on the version of the
vulnerable gem, and make modifications if necessary to allow the gem
to be updated to a version within this range.

You have several choices for how to update the gem, depending upon
how conservative or aggressive you want to be with the dependency
update (in terms of the size of version bumps and the number of
gems affected). Being too aggressive with the update carries the risk
of introducing changes that break Service Broker functionality.
Some examples, ranging from least conservative to most conservative:

1. To update the vulnerable gem and all of its dependencies.

   ```
   docker compose run tests bundle update <vulnerable-gem>
   ```

1. To update only the vulnerable gem (i.e. not its dependencies):

   ```
   docker compose run tests bundle update --conservative <vulnerable-gem>
   ```

1. To update only the vulnerable gem's patch version:

   ```
   docker compose run tests bundle update --patch --conservative <vulnerable-gem>
   ```

After running any of the above commands, you will want to test
Service Broker functionality as described in the
[Testing Functionality After Dependency Version Changes](#testing-functionality-after-dependency-version-changes)
section below.

### Updating All Dependencies at Once

If you are feeling especially lucky, you might be tempted to update
all dependencies (direct and indirect), and then build and test to
verify that Service Broker functionality has not been broken.
This would be done as follows:

   ```
   docker compose run tests bundle update
   ```

However, the chances that such a sweeping change will not break
functionality is rather slim. The recommended approach is to update gem
dependencies either singularly, or by dependency group, and test
Service Broker functionality for each version change. This process is
a bit tedious, but the chances of success are much better.

The choices of how to update each gem are the same as those listed
in the
[Finding and Fixing Security Vulnerabilities](#finding-and-fixing-security-vulnerabilities)
section above.

After any gem versions have been updated, you will want to test
Service Broker functionality as described in the
[Testing Functionality After Dependency Version Changes](#testing-functionality-after-dependency-version-changes)
section below.

### Updating by Dependency Group

It is possible to perform gem updates on a per-dependency-group basis.
However, it should be noted that because updating dependencies by
group represents a rather broad change, the chances of breaking
Service Broker functionality using this method may be high.

For example, to update `development` dependencies for the Service Broker:

   ```
   docker compose run tests bundle update --group development
   ```

Or, to update `test` and `development` dependencies:

   ```
   docker compose run tests bundle update --group test development
   ```

After any gem versions have been updated, you will want to test
Service Broker functionality as described in the
[Testing Functionality After Dependency Version Changes](#testing-functionality-after-dependency-version-changes)
section below.

### Testing Functionality After Dependency Version Changes

After any gem versions are updated, you will want to test Service
Broker functionality by running the unit tests and local integration
tests:

   ```
   ./dev/build
   ./dev/test_unit
   ./dev/test_integration
   ```

Complete end-to-end Service Broker testing should also be performed
by commiting and pushing changes to a branch of this repo.

## Releases

1. Based on the unreleased content, determine the new version number and update
   the [VERSION](VERSION) file. This project uses [semantic versioning](https://semver.org/).
1. Ensure the [changelog](CHANGELOG.md) is up to date with the changes included in the release.
1. Ensure the [open source acknowledgements](NOTICES.txt) are up to date with the dependencies,
   and update the file if there have been any new or changed dependencies since the last release.
1. Commit these changes - `Bump version to x.y.z` is an acceptable commit message.
1. Once your changes have been reviewed and merged into master, tag the version
   using `git tag -s v0.1.1`. Note this requires you to be  able to sign releases.
   Consult the [github documentation on signing commits](https://help.github.com/articles/signing-commits-with-gpg/)
   on how to set this up. `vx.y.z` is an acceptable tag message.
1. Push the tag: `git push vx.y.z` (or `git push origin vx.y.z` if you are working
   from your local machine).

When releasing a new version of the Service Broker, you will need to upload a
ZIP file with the release of the repository with all dependencies.

1. Verify that `dev/manifest.txt` includes all relevant top-level directories
   and files. These will be copied into a temporary `pkg` directory used when
   zipping, to avoid including unnecessary files in our ZIP.
2. Run the `./dev/build` script, which will run `bundle pack` with the cache_all
   config set to true, which creates a `vendor/cache/` directory with the project dependencies. 
   It will also produce a ZIP file of the project which includes this directory.
3. Attach the ZIP file to the release draft; the CI for the VMWare Tanzu Tile
   will use this artifact.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
