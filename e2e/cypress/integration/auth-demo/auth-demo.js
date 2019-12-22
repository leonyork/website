import { Given } from "cypress-cucumber-preprocessor/steps";

const AUTH_OPTIONS_ID = "auth-options"

Given(`I visit the auth-demo page`, () => {
  cy.visit("/auth-demo")
})

Then(`I see the {string} button`, (buttonText) => {
  getButton(buttonText)
})

Then(`I can click the {string} button`, (buttonText) => {
  getButton(buttonText).click()
})

Then(`I can see the text {string}`, (text) => {
  cy.get(`body`).contains(text).should('be.visible') 
})

Then(`I can authenticate and authorize`, () => {
  //Login
  cy.get(`input[name="login"]`).type(`a`)
  cy.get(`input[name="password"]`).type(`a`)
  cy.get('form').submit()
  //Authorize
  cy.get('form').submit()
})

Then(`I wait for the page to load`, () => {
  cy.wait(4000)
})

Then(`I can save the message {string}`, (message) => {
  cy.get(`input[id="formMessage"]`).type(`{selectall}{backspace}${message}`)
  cy.get('form').submit()
})

const getButton = (buttonText) => {
  cy.get(`div[id="${AUTH_OPTIONS_ID}"]`).find(`button:visible`).as(`button`)
  cy.get(`@button`).invoke('text').then((str) => expect(str).to.equal(buttonText))
  return cy.get(`@button`)
}
