Feature: Provisioning

  Scenario: Provision resource with incorrect HTTP basic auth credentials
    When my HTTP basic auth credentials are incorrect
    And I PUT "/v2/service_instances/9b292a9c-af66-4797-8d98-b30801f32a77" with body:
    """
    {
      "context": {
        "organization_guid": "e027f3f6-80fe-4d22-9374-da23a035ba0a",
        "space_guid": "8c56f85c-c16e-4158-be79-5dac74f970db"
      },
      "service_id": "cfa8d6c0-105d-45e7-8510-2811bc57a186",
      "plan_id": "52201f0a-b370-493a-ac2b-e4eabf6b050f",
      "organization_guid": "e027f3f6-80fe-4d22-9374-da23a035ba0a",
      "space_guid": "8c56f85c-c16e-4158-be79-5dac74f970db",
      "parameters": {
        "parameter1": 1,
        "parameter2": "foo"
      }
    }
    """
    Then the HTTP response status code is "401"

  Scenario: Provision resource
    When I PUT "/v2/service_instances/9b292a9c-af66-4797-8d98-b30801f32a77" with body:
    """
    {
      "context": {
        "organization_guid": "e027f3f6-80fe-4d22-9374-da23a035ba0a",
        "space_guid": "8c56f85c-c16e-4158-be79-5dac74f970db"
      },
      "service_id": "cfa8d6c0-105d-45e7-8510-2811bc57a186",
      "plan_id": "52201f0a-b370-493a-ac2b-e4eabf6b050f",
      "organization_guid": "e027f3f6-80fe-4d22-9374-da23a035ba0a",
      "space_guid": "8c56f85c-c16e-4158-be79-5dac74f970db",
      "parameters": {
        "parameter1": 1,
        "parameter2": "foo"
      }
    }
    """
    Then the HTTP response status code is "200"
    And the JSON should be {}
