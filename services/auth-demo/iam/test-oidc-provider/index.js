const { Provider } = require('oidc-provider');
const configuration = {
    responseTypes: [
        'token',
    ],
    clients: [{
        client_id: 'test',
        client_secret: 'test',
        redirect_uris: ['http://localhost:3000/auth-demo'],
        grant_types: ['implicit'],
        response_types: ['token'],
        token_endpoint_auth_method: 'none'
    }],
    features: {
        ietfJWTAccessTokenProfile: { enabled: true, ack: 2 },
    },
    formats: {
        AccessToken(ctx, token) {
            return 'jwt'
        }
    },
    async findAccount(ctx, id) {
        const actualId = `account-id-${id}`
        return {
            accountId: actualId,
            async claims(use, scope) { return { sub: actualId }; },
        }
    },
    routes: {
        authorization: '/oauth2/authorize',
        end_session: '/logout',
        jwks: '/.well-known/jwks.json',
        userinfo: '/oauth2/userInfo'
    },
    async postLogoutSuccessSource(ctx) {
        ctx.body = `<!DOCTYPE html>
      <head>
      <title>Sign-out Success</title>
      </head>
      <body>
      <script>window.location.href='http://localhost:3000/auth-demo';</script>
      </body>
      </html>`
    },
    async logoutSource(ctx, form) {
        // @param ctx - koa request context
        // @param form - form source (id="op.logoutForm") to be embedded in the page and submitted by
        //   the End-User
        ctx.body = `<!DOCTYPE html>
      <head>
      <title>Logout Request</title>
      </head>
      <body>
        ${form}
        <input type="hidden" form="op.logoutForm" value="yes" name="logout" />
        <script>document.getElementById("op.logoutForm").submit();</script>
      </body>
      </html>`
    }
};

const oidc = new Provider('http://localhost:3000', configuration);

//Allow redirect to localhost
const { invalidate: orig } = oidc.Client.Schema.prototype;

oidc.Client.Schema.prototype.invalidate = function invalidate(message, code) {
    if (code === 'implicit-force-https' || code === 'implicit-forbid-localhost') {
        return;
    }

    orig.call(this, message);
};

// Just expose a server standalone
oidc.listen(3002, () => {
    console.log(`Example: http://localhost:3002/oauth2/authorize?response_type=token&client_id=test&scope=openid&redirect_url=${encodeURI('http://localhost:3000/auth-demo')}`)
    console.log('Well known config: http://localhost:3002/.well-known/openid-configuration');
});

