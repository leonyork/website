'use strict';

const { UserRepository } = require('../../repositories/user.repository');
const dynamo = require('../../dynamodb.factory')
const userRepository = new UserRepository(dynamo)

exports.handler = async(event, context) => {
    try {
        const response = await userRepository.put({ id: event.pathParameters.id, content: JSON.parse(event.body) });
        return {
            statusCode: response ? 200 : 201,
            body: event.body,
        }
    } catch (err) {
        if (!err.statusCode) { console.log(err); }
        return {
            statusCode: err.statusCode || 500,
            body: JSON.stringify(err)
        }
    }
};