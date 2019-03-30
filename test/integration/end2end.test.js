const request = require('supertest');
const jwt = require('jsonwebtoken');
var jwkToPem = require('jwk-to-pem');
if (!process.env.USER_STORE_API_SECURED_ISSUER) {
    require('dotenv').config();
}
if (!process.env.USER_STORE_API_SECURED_TEST_URL) {
    require('./helper/severless-offline');
} else {
    jest.setTimeout(10000);
}
const requestUserApi = () => request(process.env.USER_STORE_API_SECURED_TEST_URL);

describe('User API', async() => {

    let key;
    let keyId;

    beforeAll(async() => {
        const response = await request(process.env.USER_STORE_API_SECURED_ISSUER).get("/.well-known/jwks.json")
        const keyJson = JSON.parse(response.text).keys[0]
        key = await jwkToPem(keyJson, { private: true });
        keyId = keyJson.kid;
    });

    it('should return 404 when getting a non-existant user', async() => {
        try {
            requestUserApi().get(`/user/1`) || fail("Should have been 404");
        } catch (err) {
            expect(err.statusCode).toEqual(404);
        }
    });

    it('should store information against a user', async() => {
        const authorization = jwt.sign({ sub: 2 }, key, { algorithm: "RS256", keyid: keyId });
        const userInfo = JSON.stringify({ name: "test" });
        await requestUserApi().put(`/user/2`).send(userInfo).set('Authorization', `Bearer ${authorization}`).expect(201);

        const response = await requestUserApi().get(`/user/2`).set('Authorization', `Bearer ${authorization}`);
        expect(response.text).toEqual(userInfo);
    });

    it('should update existing information stored against a user', async() => {
        const authorization = jwt.sign({ sub: 3 }, key, { algorithm: "RS256", keyid: keyId });
        const userInfo1 = JSON.stringify({ name: "test1" });
        const userInfo2 = JSON.stringify({ name: "test2" });
        await requestUserApi().put(`/user/3`).send(userInfo1).set('Authorization', `Bearer ${authorization}`).expect(201);
        await requestUserApi().put(`/user/3`).send(userInfo2).set('Authorization', `Bearer ${authorization}`).expect(200);

        const response = await requestUserApi().get(`/user/3`).set('Authorization', `Bearer ${authorization}`);
        expect(response.text).toEqual(userInfo2);
    });

    it('should store user info against the id and not update other ids', async() => {
        const authorization4 = jwt.sign({ sub: 4 }, key, { algorithm: "RS256", keyid: keyId });
        const authorization5 = jwt.sign({ sub: 5 }, key, { algorithm: "RS256", keyid: keyId });
        const userInfo1 = JSON.stringify({ name: "test1" });
        const userInfo2 = JSON.stringify({ name: "test2" });
        await requestUserApi().put(`/user/4`).send(userInfo1).set('Authorization', `Bearer ${authorization4}`).expect(201);
        await requestUserApi().put(`/user/5`).send(userInfo2).set('Authorization', `Bearer ${authorization5}`).expect(201);

        const response1 = await requestUserApi().get(`/user/4`).set('Authorization', `Bearer ${authorization4}`);
        expect(response1.text).toEqual(userInfo1);
        const response2 = await requestUserApi().get(`/user/5`).set('Authorization', `Bearer ${authorization5}`);
        expect(response2.text).toEqual(userInfo2);
    });

    it("should not be able to update a user that the authorization header doesn't give permission to", async() => {
        const authorization = jwt.sign({ sub: 2 }, key, { algorithm: "RS256", keyid: keyId });
        const userInfo1 = JSON.stringify({ name: "test" });
        try {
            await requestUserApi().put(`/user/4`).send(userInfo1).set('Authorization', `Bearer ${authorization}`) || fail("Should have been 403");
        } catch (err) {
            expect(err.status).toEqual(403)
        }
        try {
            await requestUserApi().get(`/user/4`).set('Authorization', `Bearer ${authorization}`) || fail("Should have been 403");
        } catch (err) {
            expect(err.status).toEqual(403)
        }
    });
});