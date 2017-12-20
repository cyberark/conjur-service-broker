Feature: HTTP Basic Auth

  Scenario: Provide incorrect HTTP basic auth credentials
    When I GET "/v2/catalog" with incorrect basic auth credentials
    Then the HTTP response status code is 401
