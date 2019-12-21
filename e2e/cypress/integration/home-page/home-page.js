import { Given } from "cypress-cucumber-preprocessor/steps";
 
Given("I visit the home page", () => {
  cy.visit("/")
})

Then(`I see {string} in the title`, (title) => {
    cy.title().should('include', title)
})