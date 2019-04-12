'use strict';

const { UserRepository } = require('../../repositories/user.repository');
const dynamo = require('../../dynamodb.factory');
const { cors } = require('../../cors')
const userRepository = new UserRepository(dynamo);

exports.handler = cors(async(event, context) => {
    console.log(event);
    let item;
    try {
        item = JSON.parse(event.body);
    } catch (err) {
        return {
            statusCode: 400,
            body: { "message": "Body supplied is not JSON data" }
        };
    }
    try {
        const response = await userRepository.put({ id: event.pathParameters.id, content: item });
        return {
            statusCode: response ? 200 : 201,
            body: JSON.stringify(item)
        };
    } catch (err) {
        console.log(`Error PUTting event ${JSON.stringify(event)}`);
        console.log(err);
        return {
            statusCode: err.statusCode || 500,
            body: JSON.stringify(err)
        };
    }
});