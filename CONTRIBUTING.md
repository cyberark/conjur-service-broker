# Contributing

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

When releasing a new version of the Service Broker, you will need to include a
ZIP file with the release of the repository with all dependencies. Running the
`./build.sh` script will run `bundle pack --all`, which creates a
`vendor/cache/` directory with the project dependencies. It will also produce a ZIP
file of the project which includes this directory. The ZIP file should be uploaded
to the release in GitHub; it will be used to build the PCF tile.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
