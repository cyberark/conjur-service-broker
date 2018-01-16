Feature: Service Broker request configuration

Scenario: A request is sent without the required X-Broker-API-Version header
  Given my request doesn't include the X-Broker-API-Version header
  When I GET "/v2/catalog"
  Then the HTTP response status code is "412"
  And the JSON at "description" should include "X-Broker-API-Version"

Scenario: Service broker has incorrect Conjur credentials
  Given I use a service broker with a bad Conjur API key
  When I make a bind request
  Then the HTTP response status code is "403"
  And the JSON should be {}

Scenario: Conjur is unavailable
  Given I use a service broker with a bad Conjur URL
  When I make a bind request
  Then the HTTP response status code is "500"
  And the JSON should be {}
