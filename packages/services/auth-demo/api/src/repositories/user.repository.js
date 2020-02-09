class UserRepository {
    get _baseParams() {
        return {
            TableName: process.env.USERS_TABLE
        };
    }

    constructor(documentClient) {
        this._documentClient = documentClient;
    }

    async get(id) {
        console.log(`Calling GET for id ${id}`);
        const params = this._createParamObject({
            Key: {
                id
            }
        });
        const response = await this._documentClient.get(params).promise();
        return response.Item;
    }

    /**
     * Returns the previous value of the user if they already existed on the database
     */
    async put(user) {
        const params = this._createParamObject({
            Item: user,
            ReturnValues: "ALL_OLD"
        });
        const response = await this._documentClient.put(params).promise();
        return response.Attributes && response.Attributes.content;
    }

    _createParamObject(additionalArgs = {}) {
        return Object.assign({}, this._baseParams, additionalArgs);
    }
}

exports.UserRepository = UserRepository;