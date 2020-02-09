import { Given } from "cypress-cucumber-preprocessor/steps";

const AUTH_OPTIONS_ID = "auth-options"

Given(`I visit the auth-demo page`, () => {
  cy.visit("/auth-demo")
})

Then(`I see the {string} button`, (buttonText) => {
  getButton(buttonText)
})

Then(`The {string} button links to the IAM login page`, (buttonText) => {
  getButton(buttonText).should('have.attr', 'href').then((href) => {
    const hrefUrl = new URL(href)
    expect(hrefUrl.host).to.equal(Cypress.env('iam_host'))
    expect(hrefUrl.pathname).to.equal("/oauth2/authorize")
    expect(hrefUrl.searchParams.get("response_type")).to.equal(Cypress.env('iam_response_type'))
    expect(hrefUrl.searchParams.get("scope")).to.equal(Cypress.env('iam_scope'))
    expect(hrefUrl.searchParams.get("redirect_uri")).to.equal(Cypress.env('iam_redirect_uri'))
    expect(hrefUrl.searchParams.get("client_id")).to.equal(Cypress.env('iam_client_id'))
  })
})

Then(`The {string} button links to the IAM logout page`, (buttonText) => {
  getButton(buttonText).should('have.attr', 'href').then((href) => {
    const hrefUrl = new URL(href)
    expect(hrefUrl.host).to.equal(Cypress.env('iam_host'))
    expect(hrefUrl.pathname).to.equal("/logout")
    expect(hrefUrl.searchParams.get("logout_uri")).to.equal(Cypress.env('iam_redirect_uri'))
    expect(hrefUrl.searchParams.get("client_id")).to.equal(Cypress.env('iam_client_id'))
  })
})

Then(`I can see the text {string}`, (text) => {
  cy.get(`body`).contains(text).should('be.visible') 
})

Then(`I can signup as user {string} with password {string}`, (username, password) => {
  cy.signup(username, password)
})

Then(`I can authorize`, () => {
  cy.authorize()
})

Then(`I wait for the page to load`, () => {
  cy.reload()
  cy.wait(4000)
})

Then(`I can save the message {string}`, (message) => {
  cy.get(`input[id="formMessage"]`).type(`{selectall}{backspace}${message}`)
  cy.get('form').submit()
  //Not ideal, but seems to cancel xhr if we browse away - ideal give some indication to the user once saved
  cy.wait(4000)
})

const getButton = (buttonText) => {
  cy.get(`div[id="${AUTH_OPTIONS_ID}"]`).find(`a:visible`).as(`button`)
  cy.get(`@button`).invoke('text').then((str) => expect(str).to.equal(buttonText))
  return cy.get(`@button`)
}
