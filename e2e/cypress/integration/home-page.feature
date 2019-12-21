Feature: Home Page
    Test the home page

    Background:
        Given I visit the home page

    Scenario: 
        Then I see "Leon York" in the title

    Scenario:
        Then I see "Projects" in the nav bar
        And I see "Links" in the nav bar

    Scenario: 
        Then I can browse to the "auth-demo" page