Feature: Provisioning

  Scenario: Provision resource with incorrect HTTP basic auth credentials
    Given my HTTP basic auth credentials are incorrect
    When I PUT "/v2/service_instances/9b292a9c-af66-4797-8d98-b30801f32a77" with body:
    """
    {
      "context": {
        "organization_guid": "e027f3f6-80fe-4d22-9374-da23a035ba0a",
        "space_guid": "8c56f85c-c16e-4158-be79-5dac74f970db"
      },
      "service_id": "c024e536-6dc4-45c6-8a53-127e7f8275ab",
      "plan_id": "3a116ac2-fc8b-496f-a715-e9a1b205d05c.community",
      "organization_guid": "e027f3f6-80fe-4d22-9374-da23a035ba0a",
      "space_guid": "8c56f85c-c16e-4158-be79-5dac74f970db",
      "parameters": {
      }
    }
    """
    Then the HTTP response status code is "401"
    And the JSON should be {}

  Scenario: Provision resource with invalid body - missing keys
    When I PUT "/v2/service_instances/9b292a9c-af66-4797-8d98-b30801f32a78" with body:
    """
    {
      "context": {
        "organization_guid": "e027f3f6-80fe-4d22-9374-da23a035ba0a",
        "space_guid": "8c56f85c-c16e-4158-be79-5dac74f970db"
      },
      "service_id": "c024e536-6dc4-45c6-8a53-127e7f8275ab",
      "not_plan_id": "3a116ac2-fc8b-496f-a715-e9a1b205d05c.community",
      "organization_guid": "e027f3f6-80fe-4d22-9374-da23a035ba0a",
      "space_guid": "8c56f85c-c16e-4158-be79-5dac74f970db",
      "parameters": {
      }
    }
    """
    Then the HTTP response status code is "400"
    And the JSON should be:
      """
      {
        "error": "ValidationError",
        "description": "The property '#/' did not contain a required property of 'plan_id'"
      }
      """


  @conjur-version-5
  Scenario: Provision resource with service broker API 2.15 or better
    When I PUT "/v2/service_instances/9b292a9c-af66-4797-8d98-b30801f32ax7" with body:
    """
    {
      "context": {
        "organization_guid": "e027f3f6-80fe-4d22-9374-da23a035ba0a",
        "space_guid": "8c56f85c-c16e-4158-be79-5dac74f970db"
        "organization_name": "my-organization",
        "space_name": "my-space"
      },
      "service_id": "c024e536-6dc4-45c6-8a53-127e7f8275ab",
      "plan_id": "3a116ac2-fc8b-496f-a715-e9a1b205d05c.community",
      "organization_guid": "e027f3f6-80fe-4d22-9374-da23a035ba0a",
      "space_guid": "8c56f85c-c16e-4158-be79-5dac74f970db",
      "parameters": {
      }
    }
    """
    Then the HTTP response status code is "201"
    And the JSON should be {}

  @conjur-version-5
  Scenario: Provision resource
    When I PUT "/v2/service_instances/9b292a9c-af66-4797-8d98-b30801f32ax7" with body:
    """
    {
      "context": {
        "organization_guid": "e027f3f6-80fe-4d22-9374-da23a035ba0a",
        "space_guid": "8c56f85c-c16e-4158-be79-5dac74f970db"
      },
      "service_id": "c024e536-6dc4-45c6-8a53-127e7f8275ab",
      "plan_id": "3a116ac2-fc8b-496f-a715-e9a1b205d05c.community",
      "organization_guid": "e027f3f6-80fe-4d22-9374-da23a035ba0a",
      "space_guid": "8c56f85c-c16e-4158-be79-5dac74f970db",
      "parameters": {
      }
    }
    """
    Then the HTTP response status code is "201"
    And the JSON should be {}

  Scenario: Update resource
    When I PATCH "/v2/service_instances/9b292a9c-af66-4797-8d98-b30801f32a77" with body:
    """
    {
      "context": {
        "organization_guid": "e027f3f6-80fe-4d22-9374-da23a035ba0a",
        "space_guid": "8c56f85c-c16e-4158-be79-5dac74f970db"
      },
      "service_id": "c024e536-6dc4-45c6-8a53-127e7f8275ab",
      "plan_id": "3a116ac2-fc8b-496f-a715-e9a1b205d05c.community",
      "parameters": {
      },
      "previous_values": {
        "plan_id": "we-only-have-one-plan"
      }
    }
    """
    Then the HTTP response status code is "200"
    And the JSON should be {}

  Scenario: Update resource with invalid body - missing keys
    When I PATCH "/v2/service_instances/9b292a9c-af66-4797-8d98-b30801f32a77" with body:
    """
    {
      "context": {
        "organization_guid": "e027f3f6-80fe-4d22-9374-da23a035ba0a",
        "space_guid": "8c56f85c-c16e-4158-be79-5dac74f970db"
      },
      "not_service_id": "c024e536-6dc4-45c6-8a53-127e7f8275ab",
      "plan_id": "3a116ac2-fc8b-496f-a715-e9a1b205d05c.community",
      "parameters": {
      },
      "previous_values": {
        "plan_id": "we-only-have-one-plan"
      }
    }
    """
    Then the HTTP response status code is "400"
    And the JSON should be:
      """
      {
        "error": "ValidationError",
        "description": "The property '#/' did not contain a required property of 'service_id'"
      }
      """

  Scenario: Update resource with invalid body - invalid service ID
    When I PATCH "/v2/service_instances/9b292a9c-af66-4797-8d98-b30801f32a77" with body:
    """
    {
      "context": {
        "organization_guid": "e027f3f6-80fe-4d22-9374-da23a035ba0a",
        "space_guid": "8c56f85c-c16e-4158-be79-5dac74f970db"
      },
      "service_id": "XXXXXXX-6dc4-45c6-8a53-127e7f8275ab",
      "plan_id": "3a116ac2-fc8b-496f-a715-e9a1b205d05c.community",
      "parameters": {
      },
      "previous_values": {
        "plan_id": "we-only-have-one-plan"
      }
    }
    """
    Then the HTTP response status code is "400"
    And the JSON should be:
      """
      {
        "error": "ValidationError",
        "description": "The property '#/service_id' value \"XXXXXXX-6dc4-45c6-8a53-127e7f8275ab\" was invalid."
      }
      """

  Scenario: Update resource with invalid body - invalid plan ID
    When I PATCH "/v2/service_instances/9b292a9c-af66-4797-8d98-b30801f32a77" with body:
    """
    {
      "context": {
        "organization_guid": "e027f3f6-80fe-4d22-9374-da23a035ba0a",
        "space_guid": "8c56f85c-c16e-4158-be79-5dac74f970db"
      },
      "service_id": "c024e536-6dc4-45c6-8a53-127e7f8275ab",
      "plan_id": "XXXXXXX-fc8b-496f-a715-e9a1b205d05c.community",
      "parameters": {
      },
      "previous_values": {
        "plan_id": "we-only-have-one-plan"
      }
    }
    """
    Then the HTTP response status code is "400"
    And the JSON should be:
      """
      {
        "error": "ValidationError",
        "description": "The property '#/plan_id' value \"XXXXXXX-fc8b-496f-a715-e9a1b205d05c.community\" was invalid."
      }
      """

  Scenario: Provision resource with invalid body - invalid service ID
    When I PUT "/v2/service_instances/9b292a9c-af66-4797-8d98-b30801f32a78" with body:
    """
    {
      "context": {
        "organization_guid": "e027f3f6-80fe-4d22-9374-da23a035ba0a",
        "space_guid": "8c56f85c-c16e-4158-be79-5dac74f970db"
      },
      "service_id": "XXXXXXX-6dc4-45c6-8a53-127e7f8275ab",
      "plan_id": "3a116ac2-fc8b-496f-a715-e9a1b205d05c.community",
      "organization_guid": "e027f3f6-80fe-4d22-9374-da23a035ba0a",
      "space_guid": "8c56f85c-c16e-4158-be79-5dac74f970db",
      "parameters": {
      }
    }
    """
    Then the HTTP response status code is "400"
    And the JSON should be:
      """
      {
        "error": "ValidationError",
        "description": "The property '#/service_id' value \"XXXXXXX-6dc4-45c6-8a53-127e7f8275ab\" was invalid."
      }
      """

  Scenario: Provision resource with invalid body - invalid plan ID
    When I PUT "/v2/service_instances/9b292a9c-af66-4797-8d98-b30801f32a78" with body:
    """
    {
      "context": {
        "organization_guid": "e027f3f6-80fe-4d22-9374-da23a035ba0a",
        "space_guid": "8c56f85c-c16e-4158-be79-5dac74f970db"
      },
      "service_id": "c024e536-6dc4-45c6-8a53-127e7f8275ab",
      "plan_id": "XXXXXXX-fc8b-496f-a715-e9a1b205d05c.community",
      "organization_guid": "e027f3f6-80fe-4d22-9374-da23a035ba0a",
      "space_guid": "8c56f85c-c16e-4158-be79-5dac74f970db",
      "parameters": {
      }
    }
    """
    Then the HTTP response status code is "400"
    And the JSON should be:
    """
    {
      "error": "ValidationError",
      "description": "The property '#/plan_id' value \"XXXXXXX-fc8b-496f-a715-e9a1b205d05c.community\" was invalid."
    }
    """

  Scenario: Provision resource with invalid parameters
    When I PUT "/v2/service_instances/9b292a9c-af66-4797-8d98-b30801f32ax7" with body:
    """
    {
      "context": {
        "organization_guid": "e027f3f6-80fe-4d22-9374-da23a035ba0a",
        "space_guid": "8c56f85c-c16e-4158-be79-5dac74f970db"
      },
      "service_id": "c024e536-6dc4-45c6-8a53-127e7f8275ab",
      "plan_id": "3a116ac2-fc8b-496f-a715-e9a1b205d05c.community",
      "organization_guid": "e027f3f6-80fe-4d22-9374-da23a035ba0a",
      "space_guid": "8c56f85c-c16e-4158-be79-5dac74f970db",
      "parameters": {
        "parameter1": 1,
        "parameter2": "foo"
      }
    }
    """
    Then the HTTP response status code is "400"
    And the JSON should be:
    """
    {
      "error": "ValidationError",
      "description": "The property '#/parameters' had more properties than the allowed 0"
    }
    """
