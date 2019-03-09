'use strict';
const AWS = require('aws-sdk');

let options = {}

console.log(`Is Offline: ${process.env.IS_OFFLINE}`);
if (process.env.IS_OFFLINE) {
    options = {
        region: 'localhost',
        endpoint: 'http://localhost:8000',
    }
}

module.exports = new AWS.DynamoDB.DocumentClient(options);