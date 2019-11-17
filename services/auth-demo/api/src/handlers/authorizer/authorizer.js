'use strict';

const jwt = require('jsonwebtoken');
const jwksClient = require('jwks-rsa');
const util = require('util');

const createPolicy = (event, context, principalId, effect) => {
    const allowedMethodArnComponents = event.methodArn.split("/").slice(0, -1);
    allowedMethodArnComponents.push(principalId);
    allowedMethodArnComponents[allowedMethodArnComponents.length - 3] = "*"; //Allow any method (GET, PUT, etc.)
    const policy = {
        principalId: principalId,
        policyDocument: {
            Version: "2012-10-17",
            Statement: [{
                Sid: "FirstStatement",
                Action: "execute-api:Invoke",
                Effect: effect,
                Resource: allowedMethodArnComponents.join("/")
            }]
        },
        context: context
    };
    console.log(JSON.stringify(policy));
    return policy;
};

const getJwksKeys = () => {
    return (header, callback) => {
        console.log(`Validating against ${process.env.USER_STORE_API_SECURED_ISSUER}`);
        const client = jwksClient({
            jwksUri: `${process.env.USER_STORE_API_SECURED_ISSUER}/.well-known/jwks.json`
        });
        client.getSigningKey(header.kid, function(err, key) {
            console.log(header.kid)
            if (err) {
                throw err;
            }
            const signingKey = key.publicKey || key.rsaPublicKey;
            console.log(signingKey);
            callback(null, signingKey);
        });
    }
}

exports.handler = (event, context, callback) => {
    console.log(JSON.stringify(event));
    console.log(JSON.stringify(context));
    try {
        var token = event.authorizationToken.split(" ")[1];
    } catch (err) { return context.fail("No Authorization header with Bearer token provided"); }

    if (!token) { return context.fail("No Authorization header with Bearer token provided"); }

    try {
        var keys = getJwksKeys();
    } catch (err) { return context.fail("Unable to get JWKS"); }

    try {
        jwt.verify(token, keys, (err, decoded) => {
            if (err) { throw err; }

            callback(null, createPolicy(event, context, decoded.sub, "Allow"));
        });
    } catch (err) { return context.fail("Invalid JWT"); }
};