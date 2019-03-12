'use strict';

const { UserRepository } = require('../../repositories/user.repository');
const dynamo = require('../../dynamodb.factory');
const userRepository = new UserRepository(dynamo);

exports.handler = async(event, context) => {
    try {
        const response = await userRepository.get(event.pathParameters.id);
        if (!response) {
            return {
                statusCode: 404,
                body: JSON.stringify({
                    message: "Not Found",
                    statusCode: 404
                })
            }
        }

        return {
            statusCode: 200,
            body: JSON.stringify(response.content)
        }
    } catch (err) {
        console.log(err);
        return {
            statusCode: err.statusCode || 500,
            body: JSON.stringify(err)
        }
    }
};