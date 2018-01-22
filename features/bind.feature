Feature: Binding

  Scenario: Bind resource
    When I make a bind request with body:
    """
    {
      "service_id": "c024e536-6dc4-45c6-8a53-127e7f8275ab",
      "plan_id": "3a116ac2-fc8b-496f-a715-e9a1b205d05c.community",
      "bind_resource": {
        "app_guid": "bb841d2b-8287-47a9-ac8f-eef4c16106f8"
      },
      "parameters": {
        "parameter1": 1,
        "parameter2": "foo"
      }
    }
    """
    Then the HTTP response status code is "201"
    And the JSON at "credentials/account" should be "cucumber"
    And the JSON at "credentials/appliance_url" should be "http://conjur"
    And the JSON at "credentials/authn_login" should be a string
    And the JSON at "credentials/authn_api_key" should be a string
    And the JSON has valid conjur credentials

  Scenario: Bind resource with invalid body - missing key
    When I make a bind request with body:
    """
    {
      "not_service_id": "c024e536-6dc4-45c6-8a53-127e7f8275ab",
      "plan_id": "3a116ac2-fc8b-496f-a715-e9a1b205d05c.community",
      "bind_resource": {
        "app_guid": "bb841d2b-8287-47a9-ac8f-eef4c16106f8"
      },
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
      "description": "The property '#/' did not contain a required property of 'service_id'"
    }
    """

  Scenario: Bind resource with existing ID
    When I make a bind request with an existing binding_id and body:
    """
    {
      "service_id": "c024e536-6dc4-45c6-8a53-127e7f8275ab",
      "plan_id": "3a116ac2-fc8b-496f-a715-e9a1b205d05c.community",
      "bind_resource": {
        "app_guid": "bb841d2b-8287-47a9-ac8f-eef4c16106f8"
      },
      "parameters": {
        "parameter1": 1,
        "parameter2": "foo"
      }
    }
    """
    Then the HTTP response status code is "409"
    And the JSON should be {}

  Scenario: Bind resource with missing app GUID
    When I make a bind request with an existing binding_id and body:
    """
    {
      "service_id": "c024e536-6dc4-45c6-8a53-127e7f8275ab",
      "plan_id": "3a116ac2-fc8b-496f-a715-e9a1b205d05c.community",
      "parameters": {
        "parameter1": 1,
        "parameter2": "foo"
      }
    }
    """
    Then the HTTP response status code is "422"
    And the JSON should be:
    """
    {
      "error": "RequiresApp",
      "description": "This service supports generation of credentials through binding an application only."
    }
    """

  Scenario: Bind resource with incorrect Conjur credentials
    When I use a service broker with a bad Conjur API key
    And I make a bind request with body:
    """
    {
      "service_id": "c024e536-6dc4-45c6-8a53-127e7f8275ab",
      "plan_id": "3a116ac2-fc8b-496f-a715-e9a1b205d05c.community",
      "bind_resource": {
        "app_guid": "bb841d2b-8287-47a9-ac8f-eef4c16106f8"
      },
      "parameters": {
        "parameter1": 1,
        "parameter2": "foo"
      }
    }
    """
    Then the HTTP response status code is "403"
    And the JSON should be {}

  Scenario: Bind resource with Conjur server error
    When I use a service broker with a bad Conjur URL
    And I make a bind request with body:
    """
    {
      "service_id": "c024e536-6dc4-45c6-8a53-127e7f8275ab",
      "plan_id": "3a116ac2-fc8b-496f-a715-e9a1b205d05c.community",
      "bind_resource": {
        "app_guid": "bb841d2b-8287-47a9-ac8f-eef4c16106f8"
      },
      "parameters": {
        "parameter1": 1,
        "parameter2": "foo"
      }
    }
    """
    Then the HTTP response status code is "500"
    And the JSON should be {}

  Scenario: Bind resource with invalid body - invalid service ID
    When I make a bind request with body:
    """
    {
      "service_id": "XXXXXXX-6dc4-45c6-8a53-127e7f8275ab",
      "plan_id": "3a116ac2-fc8b-496f-a715-e9a1b205d05c.community",
      "bind_resource": {
        "app_guid": "bb841d2b-8287-47a9-ac8f-eef4c16106f8"
      },
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
      "description": "The property '#/service_id' value \"XXXXXXX-6dc4-45c6-8a53-127e7f8275ab\" was invalid."
    }
    """

  Scenario: Bind resource with invalid body - invalid plan ID
    When I make a bind request with body:
    """
    {
      "service_id": "c024e536-6dc4-45c6-8a53-127e7f8275ab",
      "plan_id": "XXXXXXX-fc8b-496f-a715-e9a1b205d05c.community",
      "bind_resource": {
        "app_guid": "bb841d2b-8287-47a9-ac8f-eef4c16106f8"
      },
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
      "description": "The property '#/plan_id' value \"XXXXXXX-fc8b-496f-a715-e9a1b205d05c.community\" was invalid."
    }
    """
