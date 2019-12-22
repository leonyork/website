Feature: Auth Demo Page
    Test the auth demo page

    Background:
        Given I visit the auth-demo page

    Scenario: Login, save a message and check it's still there when I log back in
        Then I see the "Login" button
        And I can click the "Login" button
        And I can authenticate and authorize
        Then I wait for the page to load
        And I can see the text "Your user id is "
        And I can see the text "Hello!"
        Then I can save the message "A different message"
        And I see the "Logout" button
        And I can click the "Logout" button
        Then I can click the "Login" button
        And I can authenticate and authorize
        And I can see the text "A different message"