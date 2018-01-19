Feature: Deprovisioning

  Scenario: Deprovision resource with incorrect HTTP basic auth credentials
    When my HTTP basic auth credentials are incorrect
    And I DELETE "/v2/service_instances/9b292a9c-af66-4797-8d98-b30801f32a77?accepts_incomplete=true&service_id=service-id-here&plan_id=plan-id-here"
    Then the HTTP response status code is "401"
    And the JSON should be {}

  Scenario: Deprovision resource
    And I DELETE "/v2/service_instances/9b292a9c-af66-4797-8d98-b30801f32a77?accepts_incomplete=true&service_id=service-id-here&plan_id=plan-id-here"
    Then the HTTP response status code is "410"
    And the JSON should be {}
