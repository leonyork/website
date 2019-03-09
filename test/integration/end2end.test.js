const request = require('supertest');

if (!process.env.TEST_URL) {
    require('./helper/severless-offline');
} else {
    jest.setTimeout(10000);
}
const requestUserApi = () => request(process.env.TEST_URL);

describe('User API', async() => {
    it('should return 404 when getting a non-existant user', async() => {
        try {
            requestUserApi().get(`/user/1`);
        } catch (err) {
            expect(err.statusCode).toEqual(404);
        }
    });

    it('should store information against a user', async() => {
        const userInfo = JSON.stringify({ name: "test" });
        await requestUserApi().put(`/user/2`).send(userInfo).expect(201);

        const response = await requestUserApi().get(`/user/2`);
        expect(response.text).toEqual(userInfo);
    });

    it('should update existing information stored against a user', async() => {
        const userInfo1 = JSON.stringify({ name: "test1" });
        const userInfo2 = JSON.stringify({ name: "test2" });
        await requestUserApi().put(`/user/3`).send(userInfo1).expect(201);
        await requestUserApi().put(`/user/3`).send(userInfo2).expect(200);

        const response = await requestUserApi().get(`/user/3`);
        expect(response.text).toEqual(userInfo2);
    });

    it('should store user info against the id and not update other ids', async() => {
        const userInfo1 = JSON.stringify({ name: "test1" });
        const userInfo2 = JSON.stringify({ name: "test2" });
        await requestUserApi().put(`/user/4`).send(userInfo1).expect(201);
        await requestUserApi().put(`/user/5`).send(userInfo2).expect(201);

        const response1 = await requestUserApi().get(`/user/4`);
        expect(response1.text).toEqual(userInfo1);
        const response2 = await requestUserApi().get(`/user/5`);
        expect(response2.text).toEqual(userInfo2);
    });
});