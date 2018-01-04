Feature: Unbinding

  Scenario: Unbind with incorrect HTTP basic auth credentials
    When I PUT "/v2/service_instances/1dedc347-64e9-4845-812f-9ab37d710f82/service_bindings/1cd14451-abca-4689-91c8-82d605852221" with body:
    """
    {
      "service_id": "4a03ca05-d41b-4de4-802f-2c6deb47f9cd",
      "plan_id": "e000cf72-4f1e-4010-9dd5-bb9c6b7983e5",
      "bind_resource": {
        "app_guid": "5e7a43f2-b3fc-4591-ab19-783389c2cb63"
      },
      "parameters": {
        "parameter1-name-here": 1,
        "parameter2-name-here": "parameter2-value-here"
      }
    }
    """
    And my HTTP basic auth credentials are incorrect
    And I DELETE "/v2/service_instances/1dedc347-64e9-4845-812f-9ab37d710f82/service_bindings/1cd14451-abca-4689-91c8-82d605852221"
    Then the HTTP response status code is "401"

  Scenario: Unbind where binding does not exist
    When I DELETE "/v2/service_instances/fe837829-2174-4c7a-8686-d3635e38b145/service_bindings/e765e6d3-3264-417f-a726-172e3c364911"
    Then the HTTP response status code is "410"
    And the JSON should be {}

  Scenario: Successful unbinding
    When I PUT "/v2/service_instances/b3b10564-6512-440e-adcb-a45cf9a7cfad/service_bindings/23d00ee2-e2c1-40e4-b5af-6d693f04bf1b" with body:
    """
    {
      "service_id": "4a03ca05-d41b-4de4-802f-2c6deb47f9cd",
      "plan_id": "e000cf72-4f1e-4010-9dd5-bb9c6b7983e5",
      "bind_resource": {
        "app_guid": "5e7a43f2-b3fc-4591-ab19-783389c2cb63"
      }, 
      "parameters": {
        "parameter1-name-here": 1,
        "parameter2-name-here": "parameter2-value-here"
      }
    }
    """
    And I DELETE "/v2/service_instances/b3b10564-6512-440e-adcb-a45cf9a7cfad/service_bindings/23d00ee2-e2c1-40e4-b5af-6d693f04bf1b"
    Then the HTTP response status code is "200"
    And the JSON should be {}

  Scenario: Unbind with incorrect Conjur credentials
    When I PUT "/v2/service_instances/0da4a0b4-9266-4664-a52e-bc87f64e1b64/service_bindings/cf79a9c0-0ae7-49b8-aeaa-84d2f6b14df0" with body:
    """
    {
      "service_id": "4a03ca05-d41b-4de4-802f-2c6deb47f9cd",
      "plan_id": "e000cf72-4f1e-4010-9dd5-bb9c6b7983e5",
      "bind_resource": {
        "app_guid": "5e7a43f2-b3fc-4591-ab19-783389c2cb63"
      }, 
      "parameters": {
        "parameter1-name-here": 1,
        "parameter2-name-here": "parameter2-value-here"
      }
    }
    """
    And I use a service broker with a bad Conjur API key
    And I DELETE "/v2/service_instances/0da4a0b4-9266-4664-a52e-bc87f64e1b64/service_bindings/cf79a9c0-0ae7-49b8-aeaa-84d2f6b14df0"
    Then the HTTP response status code is "403"

  Scenario: Unbind with Conjur unavailable
    When I PUT "/v2/service_instances/0da4a0b4-9266-4664-a52e-bc87f64e1b64/service_bindings/cf79a9c0-0ae7-49b8-aeaa-84d2f6b14df0" with body:
    """
    {
      "service_id": "4a03ca05-d41b-4de4-802f-2c6deb47f9cd",
      "plan_id": "e000cf72-4f1e-4010-9dd5-bb9c6b7983e5",
      "bind_resource": {
        "app_guid": "5e7a43f2-b3fc-4591-ab19-783389c2cb63"
      }, 
      "parameters": {
        "parameter1-name-here": 1,
        "parameter2-name-here": "parameter2-value-here"
      }
    }
    """
    And I use a service broker with a bad Conjur URL
    And I DELETE "/v2/service_instances/0da4a0b4-9266-4664-a52e-bc87f64e1b64/service_bindings/cf79a9c0-0ae7-49b8-aeaa-84d2f6b14df0"
    Then the HTTP response status code is "500"
