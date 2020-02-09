Feature: Home Page
    Test the home page

    Background:
        Given I visit the home page

    Scenario: The title is correct
        Then I see "Leon York" in the title

    Scenario: The nav bar is correct
        Then I see "Projects" in the nav bar
        And I see "Links" in the nav bar

    Scenario: I can browse to other pages
        Then I can browse to the "auth-demo" page