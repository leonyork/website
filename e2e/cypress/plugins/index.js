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

const micro = require("micro");
const puppeteer = require("puppeteer");
const url = require("url");
 
module.exports = async (on, config) => {
  console.log(config)
  config.env = {
    ...config.env,
    ...{"iam_host": process.env.COGNITO_HOST,
    "iam_response_type": "token",
    "iam_scope": "openid",
    "iam_redirect_uri": process.env.REDIRECT_URL,
    "iam_client_id": process.env.CLIENT_ID,
    "iam_user_pool_id": process.env.USER_POOL_ID,
    }
  }
  console.log(config.env)

  on('file:preprocessor', cucumber())

  /**
   * See https://stackoverflow.com/questions/51208998/how-to-login-in-auth0-in-an-e2e-test-with-cypress
   */
  const login = async (username, password) => {
    const browser = await puppeteer.launch({ headless: true })
    const page = await browser.newPage()
    await page.goto(`https://${config.env.iam_host}/oauth2/authorize?response_type=${config.env.iam_response_type}&scope=${config.env.iam_scope}&client_id=${config.env.iam_client_id}&redirect_uri=${config.env.iam_redirect_uri}`)
    await page.waitFor("input#signInFormUsername")
    await page.waitFor("input.btn.btn-primary.submitButton-customizable")
    await page.type("input#signInFormUsername", username)
    await page.type("input#signInFormPassword", password)
    await page.click("input.btn.btn-primary.submitButton-customizable").then(() => page.waitForNavigation({ waitUntil: 'load' }))
    await browser.close()
    return page.url()
  }
  const server = micro(async (req, res) => {
      // expect request Url of form `http://localhost:3005?username=blahblah&password=blahblah
      const data = url.parse(req.url, true);
      const { username, password } = data.query;
      console.log(`Logging ${username} in.`);
      return login(username, password);
  });

  server.listen(3005);

  return config
}