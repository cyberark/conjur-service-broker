package main

import (
	"fmt"
	"os"

	"github.com/cyberark/conjur-api-go/conjurapi"
	"github.com/cyberark/conjur-api-go/conjurapi/authn"
)

func main() {
	// This health check should connect to Conjur as the
	// buildpack is going to, so if the follower URL
	// is configured, use that instead of the appliance
	// URL for the service broker.
	followerURL := os.Getenv("CONJUR_FOLLOWER_URL")
	if len(followerURL) > 0 {
		os.Setenv("CONJUR_APPLIANCE_URL", followerURL)
	}

	config, err := conjurapi.LoadConfig()
	printAndExitIfError(err)

	conjur, err := conjurapi.NewClientFromKey(config,
		authn.LoginPair{
			Login:  os.Getenv("CONJUR_AUTHN_LOGIN"),
			APIKey: os.Getenv("CONJUR_AUTHN_API_KEY"),
		},
	)
	printAndExitIfError(err)

	// Check policy permission to confirm configuration works
	account := os.Getenv("CONJUR_ACCOUNT")
	policyIdentifier := os.Getenv("CONJUR_POLICY")
	if len(policyIdentifier) == 0 {
		policyIdentifier = "root"
	}
	policyID := fmt.Sprintf("%s:policy:%s", account, policyIdentifier)
	_, err = conjur.CheckPermission(policyID, "read")
	printAndExitIfError(err)

	fmt.Println("Successfully connected to Conjur.")
}

func printAndExitIfError(err error) {
	if err == nil {
		return
	}
	os.Stderr.WriteString("There is an issue with your Conjur configuration.\n")
	os.Stderr.WriteString(err.Error())
	os.Exit(1)
}
