Feature: HTTP Basic Auth

  Scenario: Catalog is returned when correct basic auth credentials are provided
    When I get "/v2/catalog" with correct basic auth credentials
    Then the HTTP response status code is "200"
    And the JSON response should be:
       """
       { "services": [
         { "name": "cyberark-conjur",
           "id":"c024e536-6dc4-45c6-8a53-127e7f8275ab",
           "description":"An open source security service that provides secrets management, machine-identity based authorization, and more.",
           "bindable":true,
           "metadata": {
             "displayName": "CyberArk Conjur",
             "imageUrl": "https://www.conjur.org/img/feature-icons/machine-identity-teal.svg",
             "providerDisplayName": "CyberArk",
             "documentationUrl": "https://www.conjur.org/api.html",
             "supportUrl":"https://www.conjur.org/support.html"
           },
           "plans": [
             { "name":"community",
               "id": "3a116ac2-fc8b-496f-a715-e9a1b205d05c.community",
               "description":"Community service plan",
               "free": true,
               "metadata": {
                 "display_name": "Conjur",
                 "bullets": [
                   "Machine Identity",
                   "Secrets management",
                   "Role-based access control"
                 ]
               }
             }
           ]
         }
       ]}
       """

  Scenario: HTTP status 401 when incorrect basic auth credentials are provided
    When I get "/v2/catalog" with incorrect basic auth credentials
    Then the HTTP response status code is "401"
