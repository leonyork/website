'use strict';
const AWS = require('aws-sdk');

let options = {};

if (process.env.IS_OFFLINE) {
    options = {
        region: 'localhost',
        endpoint: 'http://localhost:8000',
        accessKeyId: 'CAN_BE_ANYTHING_AS_ONLY_USED_LOCALLY', 
        secretAccessKey: 'CAN_BE_ANYTHING_AS_ONLY_USED_LOCALLY',
    }
}

module.exports = new AWS.DynamoDB.DocumentClient(options);