Feature: Health Check
  Scenario: Healthy
    # Use working appliance URL as follower URL to make health check pass.
    When I run the buildpack health check script with env CONJUR_FOLLOWER_URL=$CONJUR_APPLIANCE_URL
    Then the exit status should be 0

  Scenario: Invalid Conjur appliance URL
    When I run the buildpack health check script with env CONJUR_APPLIANCE_URL=not-an-appliance-url
    Then the output includes 'There is an issue with your Conjur configuration.'
    And the exit status should be 1

Scenario: Empty Conjur Follower URL
    When I run the buildpack health check script with env CONJUR_FOLLOWER_URL=
    Then the output includes 'Successfully connected to Conjur.'
    And the exit status should be 0

  Scenario: Invalid Conjur Follower URL
    When I run the buildpack health check script with env CONJUR_FOLLOWER_URL=not-a-follower-url
    Then the output includes 'There is an issue with your Conjur configuration.'
    And the exit status should be 1
