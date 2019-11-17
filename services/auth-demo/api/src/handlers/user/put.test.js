const { UserRepository } = require('../../repositories/user.repository');

jest.mock('../../repositories/user.repository');

const mockUserRespository = {
    put: jest.fn()
}

UserRepository.mockImplementation(() => mockUserRespository);

const handler = require('./put').handler;

describe("put handler", async() => {
    it("should call the user repository with the id from the path parameters and return the content", async() => {
        const mockResponse = { id: 1, content: `{"name":"test"}` };
        mockUserRespository.put.mockResolvedValue(mockResponse);

        const event = { pathParameters: { id: mockResponse.id }, body: mockResponse.content };
        const actualResponse = await handler(event, null);

        expect(mockUserRespository.put).toHaveBeenCalledWith({ id: mockResponse.id, content: JSON.parse(mockResponse.content) });
        expect(actualResponse.body).toEqual(JSON.stringify(JSON.parse(mockResponse.content)));
        expect(actualResponse.statusCode).toEqual(200);
    });

    it("should return a 201 if the respository responds with no existing data", async() => {
        const mockResponse = undefined
        mockUserRespository.put.mockResolvedValue(mockResponse);

        const event = { pathParameters: { id: 1 }, body: `{"name":"test"}` };
        const actualResponse = await handler(event, null);

        expect(actualResponse.body).toEqual(JSON.stringify({ name: "test" }));
        expect(actualResponse.statusCode).toEqual(201);
    });

    it("should return a 400 if the body is not JSON", async() => {
        const event = { pathParameters: { id: "1" }, body: "not json" };
        const actualResponse = await handler(event, null);

        expect(actualResponse.statusCode).toEqual(400);
    });

    it("should return the status code of any error the repository throws", async() => {
        const mockResponse = undefined;
        mockUserRespository.put.mockImplementation(() => { throw { statusCode: 418, message: "Test" }; })

        const event = { pathParameters: { id: 1 }, body: `{"name":"test"}` };
        const actualResponse = await handler(event, null);

        expect(actualResponse.statusCode).toEqual(418);
        expect(actualResponse.body).toContain("Test");
    });

    it("should return 500 if there is no status code in any error the repository throws", async() => {
        const mockResponse = undefined;
        mockUserRespository.put.mockImplementation(() => { throw { message: "Test" }; })

        const event = { pathParameters: { id: 1 }, body: `{"name":"test"}` };
        const actualResponse = await handler(event, null);

        expect(actualResponse.statusCode).toEqual(500);
        expect(actualResponse.body).toContain("Test");
    });
});