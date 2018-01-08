Feature: Catalog

  Scenario: Retrieve catalog with incorrect HTTP basic auth credentials
    When my HTTP basic auth credentials are incorrect
    And I GET "/v2/catalog"
    Then the HTTP response status code is "401"
    And the JSON should be {}

  Scenario: Retrieve catalog
    When I GET "/v2/catalog"
    Then the HTTP response status code is "200"
    And the result is not empty
    And there is a list of services
    And the singular service is named "cyberark-conjur"
    And the singular plan is named "community"
