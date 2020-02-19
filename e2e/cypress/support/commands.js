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

Cypress.Commands.add('login', (username, password) => {
    //See plugins
    const reqUrl = `http://localhost:3005?username=${encodeURIComponent(username)}&password=${encodeURIComponent(password)}`;

    console.log("Beginning login.", reqUrl);

    try {
        cy.request(reqUrl).then(res => {
            const url = res.body;
            cy.visit(url)
        });
    }
    catch (err) {
        cy.log(err)
    }
})