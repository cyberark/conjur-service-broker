Feature: Service Broker request configuration

Scenario: A request is sent without the required X-Broker-API-Version header
  Given my request doesn't include the X-Broker-API-Version header
  When I GET "/v2/catalog"
  Then the HTTP response status code is "412"
  And the JSON at "description" should include "X-Broker-API-Version"
