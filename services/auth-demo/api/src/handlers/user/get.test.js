const { UserRepository } = require('../../repositories/user.repository');

jest.mock('../../repositories/user.repository');

const mockUserRespository = {
    get: jest.fn()
}

UserRepository.mockImplementation(() => mockUserRespository);

const handler = require('./get').handler;

describe("get handler", async() => {
    it("should call the user repository with the id from the path parameters and return the content", async() => {
        const mockResponse = { id: 1, content: "test" };
        mockUserRespository.get.mockResolvedValue(mockResponse);

        const event = { pathParameters: { id: 1 } };
        const actualResponse = await handler(event, null);

        expect(mockUserRespository.get).toHaveBeenCalledWith(event.pathParameters.id);
        expect(actualResponse.body).toEqual(JSON.stringify(mockResponse.content));
        expect(actualResponse.statusCode).toEqual(200);
    });

    it("should return a 404 if the repository returns an undefined value is returned from the respository", async() => {
        const mockResponse = undefined;
        mockUserRespository.get.mockResolvedValue(mockResponse);

        const event = { pathParameters: { id: 1 } };
        const actualResponse = await handler(event, null);

        expect(actualResponse.statusCode).toEqual(404);
    });

    it("should return the status code of any error the repository throws", async() => {
        const mockResponse = undefined;
        mockUserRespository.get.mockImplementation(() => { throw { statusCode: 418, message: "Test" }; })

        const event = { pathParameters: { id: 1 } };
        const actualResponse = await handler(event, null);

        expect(actualResponse.statusCode).toEqual(418);
        expect(actualResponse.body).toContain("Test");
    });

    it("should return 500 if there is no status code in any error the repository throws", async() => {
        const mockResponse = undefined;
        mockUserRespository.get.mockImplementation(() => { throw { message: "Test" }; })

        const event = { pathParameters: { id: 1 } };
        const actualResponse = await handler(event, null);

        expect(actualResponse.statusCode).toEqual(500);
        expect(actualResponse.body).toContain("Test");
    });
});