Feature: Binding

  Scenario: Bind resource

    When I PUT "/v2/service_instances/9b292a9c-af66-4797-8d98-b30801f32a77/service_bindings/1020cc1d-eff2-44d0-a958-f11ca06ebc68" with body:
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
    And the JSON should be:
    """
    {
      "credentials": {
        "account": "",
        "appliance_url": "",
        "authn_login": "",
        "authn_api_key": ""
      }
    }
    """

  Scenario: Bind resource with incorrect Conjur credentials
    When I use a service broker with an invalid Conjur key
    And I PUT "/v2/service_instances/9b292a9c-af66-4797-8d98-b30801f32a77/service_bindings/1020cc1d-eff2-44d0-a958-f11ca06ebc68" with body:
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
    Then the HTTP response status code is "401"


  Scenario: Bind resource with Conjur server error
    When I use a service broker with an invalid Conjur url
    And I PUT "/v2/service_instances/9b292a9c-af66-4797-8d98-b30801f32a77/service_bindings/1020cc1d-eff2-44d0-a958-f11ca06ebc68" with body:
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
