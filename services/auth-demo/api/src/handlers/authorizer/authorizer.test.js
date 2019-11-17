const jwksClient = require('jwks-rsa');
const jwt = require('jsonwebtoken');
const createCert = require('create-cert');

jest.mock('jwks-rsa');

const mockJwksClient = {
    getSigningKey: jest.fn()
}

jwksClient.mockImplementation(() => mockJwksClient);

const handler = require('./authorizer').handler;

describe("authorizer", async() => {
    it("should return the correct policy if the JWT sub is set", async() => {
        const keys = await createCert();
        mockJwksClient.getSigningKey.mockImplementation((kid, func) => {
            func(null, { publicKey: keys.cert })
        })
        const token = jwt.sign({ sub: "2" }, keys.key, { algorithm: "RS256" });
        const event = { authorizationToken: `Bearer ${token}`, methodArn: "arn:aws:execute-api:us-east-1:random-account-id:random-api-id/dev/PUT/user/1" };
        const context = { fail: jest.fn() };
        const callback = jest.fn();
        handler(event, context, callback);

        expect(context.fail).not.toHaveBeenCalled();
        expect(callback).toHaveBeenCalledWith(null, {
            principalId: "2",
            policyDocument: {
                Version: "2012-10-17",
                Statement: [{
                    Sid: "FirstStatement",
                    Action: "execute-api:Invoke",
                    Effect: "Allow",
                    Resource: "arn:aws:execute-api:us-east-1:random-account-id:random-api-id/dev/*/user/2"
                }]
            },
            context: context
        });
    });

    it("should call context.fail and not call the callback when there is an error in the jwks client", async() => {
        mockJwksClient.getSigningKey.mockImplementation((kid, func) => {
            func({ test: error }, null)
        })

        const event = { authorizationToken: "Bearer 12345" };
        const context = { fail: jest.fn() };
        const callback = jest.fn();
        handler(event, context, callback);

        expect(context.fail).toHaveBeenCalled();
        expect(callback).not.toHaveBeenCalled();
    });

    it("should call context.fail and not call the callback when the JWT is signed by a different key", async() => {
        const keys = await createCert();
        const otherKeys = await createCert();
        mockJwksClient.getSigningKey.mockImplementation((kid, func) => {
            func(null, { publicKey: keys.cert })
        })
        const token = jwt.sign({ sub: "12345" }, otherKeys.key, { algorithm: "RS256" });
        const event = { authorizationToken: `Bearer ${token}`, methodArn: "123" };
        const context = { fail: jest.fn() };
        const callback = jest.fn();
        handler(event, context, callback);

        expect(context.fail).toHaveBeenCalled();
        expect(callback).not.toHaveBeenCalled();
    });

    it("should call context.fail and not call the callback when the JWT has expired", async() => {
        const keys = await createCert();
        mockJwksClient.getSigningKey.mockImplementation((kid, func) => {
            func(null, { publicKey: keys.cert })
        })
        const token = jwt.sign({ sub: "2", exp: 1 }, keys.key, { algorithm: "RS256" });
        const event = { authorizationToken: `Bearer ${token}`, methodArn: "arn:aws:execute-api:us-east-1:random-account-id:random-api-id/dev/PUT/user/1" };
        const context = { fail: jest.fn() };
        const callback = jest.fn();
        handler(event, context, callback);

        expect(context.fail).toHaveBeenCalled();
        expect(callback).not.toHaveBeenCalled();
    });
});