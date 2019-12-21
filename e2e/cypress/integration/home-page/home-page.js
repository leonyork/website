import { Given } from "cypress-cucumber-preprocessor/steps";
 
Given(`I visit the home page`, () => {
  cy.visit("/")
})

Then(`I see {string} in the title`, (title) => {
    cy.title().should('include', title)
})

Then(`I see {string} in the nav bar`, (element) => {
    cy.get("nav").contains(element)
})

Then(`I can browse to the {string} page`, (page) => {
    cy.get(`a[href="${page}"]`).first().click()
    //This checks that we've navigated to the page
    cy.location('pathname').should('include', page)
    //Use this to check that the page was a 200
    cy.visit(page)
})