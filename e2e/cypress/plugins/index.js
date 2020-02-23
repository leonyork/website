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

const AWS = require('aws-sdk');
 
module.exports = async (on, config) => {
  console.log(config)
  config.env = {
    ...config.env,
    ...{"region": process.env.REGION,
    "iam_host": process.env.COGNITO_HOST,
    "iam_response_type": "token",
    "iam_scope": "openid",
    "iam_redirect_uri": process.env.REDIRECT_URL,
    "iam_client_id": process.env.CLIENT_ID,
    "iam_user_pool_id": process.env.USER_POOL_ID,
    }
  }
  console.log(config.env)

  on('file:preprocessor', cucumber())

  //Create a user to use for the test
  const cognito = new AWS.CognitoIdentityServiceProvider({"region": config.env.region})
  const username = 'test@test.com'
  console.log(`Creating user with username ${username}`)
  try {
    console.log("delete user...")
    const response = await cognito.adminDeleteUser({"UserPoolId": config.env.iam_user_pool_id, "Username": username}).promise()
    console.log(response)
  } catch (err) {
    console.log(err)
  }

  try {
    console.log("signup...")
    let response = await cognito.signUp({"ClientId": config.env.iam_client_id, "Username": username, "Password": "Passw0rd!"}).promise()
    console.log(response)
    console.log("confirm...")
    response = await cognito.adminConfirmSignUp({"UserPoolId": config.env.iam_user_pool_id, "Username": username}).promise()
    console.log(response)
  } catch (err) {
    console.log(err)
  }

  /**
   * See https://stackoverflow.com/questions/51208998/how-to-login-in-auth0-in-an-e2e-test-with-cypress
   */
  const login = async (username, password) => {
    const browser = await puppeteer.launch({
      args: [
          '--disable-gpu',
          '--disable-dev-shm-usage',
          '--disable-setuid-sandbox',
          '--no-first-run',
          '--no-zygote',
          '--no-sandbox',
          '--single-process',
          '--headless',
          '--test-type'
      ],
    })
    const page = await browser.newPage()
    await page.goto(`https://${config.env.iam_host}/oauth2/authorize?response_type=${config.env.iam_response_type}&scope=${config.env.iam_scope}&client_id=${config.env.iam_client_id}&redirect_uri=${config.env.iam_redirect_uri}`)
    await page.waitFor("input#signInFormUsername")
    await page.waitFor("input.btn.btn-primary.submitButton-customizable")
    await page.type("input#signInFormUsername", username)
    console.log("Typed username")
    await page.type("input#signInFormPassword", password)
    console.log("Typed password")
    await Promise.all([
      page.waitForNavigation({waitUntil: 'networkidle0'}),
      page.click("input.btn.btn-primary.submitButton-customizable")
     ])
    console.log("Submitted login")
    const url = await page.url()
    await browser.close()
    console.log(`Redirected to url ${url}`)
    return url
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