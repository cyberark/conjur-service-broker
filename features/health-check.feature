Feature: Health Check
  Scenario: Healthy
    # Use working appliance URL as follower URL to make health check pass.
    When I run the health check script with env CONJUR_FOLLOWER_URL=$CONJUR_APPLIANCE_URL
    Then the exit status should be 0

  Scenario: Invalid Conjur appliance URL
    When I run the health check script with env CONJUR_APPLIANCE_URL=not-an-appliance-url
    Then the output includes 'There is an issue with your Conjur configuration.'
    And the exit status should be 1

  Scenario: Invalid Conjur credentials
    When I run the health check script with env CONJUR_AUTHN_LOGIN=not-a-login
    Then the output includes 'There is an issue with your Conjur configuration.'
    And the exit status should be 1

  Scenario: Policy Branch is Set
    When I run the health check script with env CONJUR_FOLLOWER_URL=$CONJUR_APPLIANCE_URL CONJUR_POLICY=$CONJUR_POLICY
    Then the output includes 'Successfully validated Conjur credentials'
    And the exit status should be 0

  Scenario: Policy Branch is Not Set
    When I run the health check script with env CONJUR_FOLLOWER_URL=$CONJUR_APPLIANCE_URL CONJUR_POLICY=
    Then the output includes 'Successfully validated Conjur credentials'
    And the exit status should be 0

  Scenario: Policy Branch Doesn't Exist
    When I run the health check script with env CONJUR_FOLLOWER_URL=$CONJUR_APPLIANCE_URL CONJUR_POLICY=nonexistent_policy
    Then the output includes 'The policy branch specified in your configuration does not exist, or is incorrect.'
    And the exit status should be 1

  @conjur-version-5
  Scenario: Login host can not access own resource
    When I run the health check script with env CONJUR_AUTHN_LOGIN=host/bad-service-broker CONJUR_AUTHN_API_KEY=$BAD_HOST_API_KEY
    Then the output includes 'Host identity not privileged to read itself.'
    And the exit status should be 1

  Scenario: Empty Conjur Follower URL
    When I run the health check script with env CONJUR_FOLLOWER_URL=
    Then the output includes 'Successfully validated Conjur credentials'
    And the exit status should be 0

  Scenario: Invalid Conjur Follower URL
    When I run the health check script with env CONJUR_FOLLOWER_URL=not-a-follower-url
    Then the output includes 'There is an issue with your CONJUR_FOLLOWER_URL value.'
    And the exit status should be 1
