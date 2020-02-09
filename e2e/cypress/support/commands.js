// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
// Cypress.Commands.add("login", (email, password) => { ... })
//
//
// -- This is a child command --
// Cypress.Commands.add("drag", { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add("dismiss", { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This will overwrite an existing command --
// Cypress.Commands.overwrite("visit", (originalFn, url, options) => { ... })

Cypress.Cookies.defaults({ whitelist: /^.*/ });

Cypress.Commands.add('signup', (username, password) => {
    const options = {
        method: 'POST',
        url: `https://${Cypress.env('iam_host')}/signup`,
        qs: {
            response_type: Cypress.env('iam_response_type'),
            scope: Cypress.env('iam_scope'),
            client_id: Cypress.env('iam_client_id'),
            redirect_uri: Cypress.env('iam_redirect_uri'),
        },
        form: true, // we are submitting a regular form body
        body: {
            username: username,
            password: password,
        },
        followRedirect: false
    }

    cy.request(options).then((response) => {
        cy.log(JSON.stringify(response))

        const url = new URL(response.headers.location)
        if (url.host == Cypress.env('iam_host')) {
            //We've failed to sign up, so we're probably running locally - try with a username with a random start to it
            //TODO: Change this so that we always generate a random email to signup with (e.g. using UUID)
            cy.signup(`${Math.random().toString(36).substring(1)}${username}`, password)
        }
        else {
            cy.visit(response.headers.location)
        }
    })
})

Cypress.Commands.add('authorize', () => {
    const options = {
        method: 'GET',
        url: `https://${Cypress.env('iam_host')}/oauth2/authorize`,
        qs: {
            response_type: Cypress.env('iam_response_type'),
            scope: Cypress.env('iam_scope'),
            client_id: Cypress.env('iam_client_id'),
            redirect_uri: Cypress.env('iam_redirect_uri'),
        },
        followRedirect: false
    }

    cy.request(options).then((response) => {
        cy.log(JSON.stringify(response))
        cy.visit(response.headers.location)
    })
})
