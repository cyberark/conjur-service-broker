#!/bin/bash -ex

function main() {
    # TODO - The commented arguments are throwing an exeception unreleated to the
    # success of the RSpec test.  We need to get this resolved and export the
    # resulting XML file to the `spec/reports` folder for Jenkins to pickup.
    rspec # --format RspecJunitFormatter --out spec/reports/test.xml

    # Skip the integration tests if the Summon variables are not present
    if [ -z "$CF_API_ENDPOINT" ]; then
        INTEGRATION_TAG="--tags ~@integration"
    else
        # Make sure all of the environment are present for the integration tests
        : ${PCF_CONJUR_ACCOUNT?"Need to set PCF_CONJUR_ACCOUNT"}
        : ${PCF_CONJUR_APPLIANCE_URL?"Need to set PCF_CONJUR_APPLIANCE_URL"}
        : ${PCF_CONJUR_USERNAME?"Need to set PCF_CONJUR_USERNAME"}
        : ${PCF_CONJUR_API_KEY?"Need to set STATE"}

        install_buildpack
    fi  

    cucumber --format junit \
    --out features/reports \
    $INTEGRATION_TAG \
    --format pretty \
    --backtrace \
    --verbose
}

function install_buildpack() {
    echo "Installing buildpack..."
    cf api "$CF_API_ENDPOINT" --skip-ssl-validation
    CF_PASSWORD=$CF_ADMIN_PASSWORD cf auth admin

    if ! cf buildpacks | grep "conjur_buildpack"; then
        # get the Conjur buildpack and upload to cf
        mkdir conjur-buildpack
        pushd conjur-buildpack
        curl -L "$(curl -s https://api.github.com/repos/cyberark/cloudfoundry-conjur-buildpack/releases/latest | \
            grep browser_download_url | \
            grep zip | \
            awk '{print $NF}' | \
            sed 's/",*//g')" > conjur-buildpack.zip
        unzip conjur-buildpack.zip
        ./upload.sh
        popd
        rm -rf conjur-buildpack
    else
        echo "Buildpack is already present."
    fi
}

main "$@"
