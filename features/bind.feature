Feature: Binding

  Scenario: Bind resource
    When I make a bind request with body:
    """
    {
      "service_id": "cfa8d6c0-105d-45e7-8510-2811bc57a186",
      "plan_id": "52201f0a-b370-493a-ac2b-e4eabf6b050f",
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

  Scenario: Bind resource with existing ID
    When I make a bind request with an existing binding_id and body:
    """
    {
      "service_id": "cfa8d6c0-105d-45e7-8510-2811bc57a186",
      "plan_id": "52201f0a-b370-493a-ac2b-e4eabf6b050f",
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
      "service_id": "cfa8d6c0-105d-45e7-8510-2811bc57a186",
      "plan_id": "52201f0a-b370-493a-ac2b-e4eabf6b050f",
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
      "error": "ValidationError",
      "description": "The property '#/' did not contain a required property of 'bind_resource'"
    }
    """

  Scenario: Bind resource with incorrect Conjur credentials
    When I use a service broker with a bad Conjur API key
    And I make a bind request with body:
    """
    {
      "service_id": "cfa8d6c0-105d-45e7-8510-2811bc57a186",
      "plan_id": "52201f0a-b370-493a-ac2b-e4eabf6b050f",
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
      "service_id": "cfa8d6c0-105d-45e7-8510-2811bc57a186",
      "plan_id": "52201f0a-b370-493a-ac2b-e4eabf6b050f",
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
