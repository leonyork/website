Feature: Auth Demo Page
    Test the auth demo page

    Background:
        Given I visit the auth-demo page

    Scenario: 
        Then I see the "Login" button
        And I can click the "Login" button
        And I can authenticate and authorize
        Then I see the "Logout" button
        And I can click the "Logout" button