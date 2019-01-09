Feature: Integration Tests

  Scenario: Service broker functions correctly with PCF 2.4
  
    Given I login to PCF and target my organization and space
    And I load a secret into Conjur
    And I create a service instance for Conjur

    When I push the sample app to PCF
    And I privilege the app to access the secret in Conjur
    And I start the app

    Then I can retrieve the secret value from the app
