Feature: HTTP Basic Auth

  Scenario: HTTP status 403 when incorrect basic auth credentials are provided
    When I get "/v2/catalog" with incorrect basic auth credentials
    Then the HTTP response status code is "401"
