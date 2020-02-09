// ***********************************************************
// This example plugins/index.js can be used to load plugins
//
// You can change the location of this file or turn off loading
// the plugins file with the 'pluginsFile' configuration option.
//
// You can read more here:
// https://on.cypress.io/plugins-guide
// ***********************************************************

const cucumber = require('cypress-cucumber-preprocessor').default
 
module.exports = (on, config) => {
  config.env = {
    ...config.env,
    ...{"iam_host": process.env.COGNITO_HOST,
    "iam_response_type": "token",
    "iam_scope": "openid",
    "iam_redirect_uri": process.env.REDIRECT_URL,
    "iam_client_id": process.env.CLIENT_ID
    }
  }
  console.log(config.env)

  on('file:preprocessor', cucumber())
  return config
}