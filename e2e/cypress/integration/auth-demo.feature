Feature: Auth Demo Page
    Test the auth demo page

    Background:
        Given I visit the auth-demo page

    @ignore
    Scenario: Login, save a message and check it's still there when I go back to the page
        Then I see the "Login" button
        And The "Login" button links to the IAM login page
        And I can signup as user "test@test.com" with password "password"
        Then I wait for the page to load
        And I can see the text "Your user id is "
        And I can see the text "Hello!"
        Then I can save the message "A different message"
        And I see the "Logout" button
        And The "Logout" button links to the IAM logout page
        Then I visit the auth-demo page
        And I can authorize
        Then I wait for the page to load
        And I can see the text "A different message"