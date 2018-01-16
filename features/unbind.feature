Feature: Unbinding

  Scenario: Unbind with incorrect HTTP basic auth credentials
    Given I make a bind request
    And my HTTP basic auth credentials are incorrect
    When I make an unbind request to the same endpoint
    Then the HTTP response status code is "401"
    And the JSON should be {}

  Scenario: Unbind where binding does not exist
    When I DELETE "/v2/service_instances/fe837829-2174-4c7a-8686-d3635e38b145/service_bindings/e765e6d3-3264-417f-a726-172e3c364911"
    Then the HTTP response status code is "410"
    And the JSON should be {}

  Scenario: Successful unbinding
    Given I make a bind request
    And the HTTP response status code is "201"
    And I keep the JSON response as "BIND_RESPONSE"
    And the JSON from "BIND_RESPONSE" has valid conjur credentials
    When I make an unbind request to the same endpoint
    Then the HTTP response status code is "200"
    And the JSON from "BIND_RESPONSE" has invalid conjur credentials
