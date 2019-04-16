# These tests only need to run once, because we use an external
# Conjur server, so we'll tag them to run with the V5 tests (the
# external server is Conjur V5 Enterprise)
@conjur-version-5
@integration
Feature: Integration Tests for PCF 2.4

  Background: 
    Given I create an org and space
    And I install the Conjur service broker

  Scenario: Service broker functions correctly with PCF 2.4 
    When I create a service instance for Conjur
    Then the policy for the org and space exists
    And the space host exists
    And the space host api key variable exists

    When I load a secret into Conjur
    And I privilege the org layer to access a secret in Conjur
    And I privilege the space layer to access a secret in Conjur
    
    And I push the sample app to PCF
    And I privilege the app host to access a secret in Conjur
    And I start the app
    Then I can retrieve the secret values from the app

    When I remove the service instance
    Then the policy for the org and space exists
    And the space host api key is stored in a variable

  Scenario: Redeploying service broker
    When I create a service instance for Conjur
    Then the policy for the org and space exists
    And the space host exists
    And the space host api key variable exists

    When I load a secret into Conjur
    And I privilege the org layer to access a secret in Conjur
    And I privilege the space layer to access a secret in Conjur
    
    And I push the sample app to PCF
    And I privilege the app host to access a secret in Conjur
    And I start the app
    Then I can retrieve the secret values from the app

    When I remove the service instance
    Then the policy for the org and space exists

    # Redeploy and run app, maintaining existing policy
    When I create a service instance for Conjur
    Then the policy for the org and space exists

    When I push the sample app to PCF
    # The app host will have a new binding ID, so we need to grant
    # permissions for the app specific secret again, but not for the
    # org/space secrets:
    And I privilege the app host to access a secret in Conjur
    And I start the app
    Then I can retrieve the secret values from the app

    When I remove the service instance
    Then the policy for the org and space exists
    And the space host api key is stored in a variable
