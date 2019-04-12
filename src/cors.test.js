const cors = require('./cors').cors;

describe("cors", async() => {
    it("should not add any CORS headers if the environment variable is not set", async() => {
        process.env.USER_STORE_API_ACCESS_CONTROL_ALLOW_ORIGIN = undefined

        const response = {
            body: "test",
            headers: {
                "test": "test"
            }
        }
        const handler = cors(async(event, context) => {
            return response
        })

        const result = await handler(undefined, undefined)
        expect(result).toEqual(response)
    });

    it("should add any CORS headers if the environment variable is set", async() => {
        process.env.USER_STORE_API_ACCESS_CONTROL_ALLOW_ORIGIN = '*'

        const response = {
            body: "test",
            headers: {
                "test": "test"
            }
        }
        const handler = cors(async(event, context) => {
            return response
        })

        const result = await handler(undefined, undefined)
        expect(result).toEqual({
            body: "test",
            headers: {
                "test": "test",
                'Access-Control-Allow-Headers': 'Authorization',
                'Access-Control-Allow-Origin': '*'
            }
        })
    });

    it("should not overwrite existing CORS Access-Control-Allow-Headers", async() => {
        process.env.USER_STORE_API_ACCESS_CONTROL_ALLOW_ORIGIN = '*'

        const response = {
            body: "test",
            headers: {
                'Access-Control-Allow-Headers': "test"
            }
        }
        const handler = cors(async(event, context) => {
            return response
        })

        const result = await handler(undefined, undefined)
        expect(result).toEqual({
            body: "test",
            headers: {
                'Access-Control-Allow-Headers': 'test',
                'Access-Control-Allow-Origin': '*'
            }
        })
    });

    it("should not overwrite existing CORS Access-Control-Allow-Origin", async() => {
        process.env.USER_STORE_API_ACCESS_CONTROL_ALLOW_ORIGIN = '*'

        const response = {
            body: "test",
            headers: {
                'Access-Control-Allow-Origin': "test"
            }
        }
        const handler = cors(async(event, context) => {
            return response
        })

        const result = await handler(undefined, undefined)
        expect(result).toEqual({
            body: "test",
            headers: {
                'Access-Control-Allow-Headers': 'Authorization',
                'Access-Control-Allow-Origin': 'test'
            }
        })
    });
});