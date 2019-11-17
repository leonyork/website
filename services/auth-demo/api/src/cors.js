'use strict';

exports.cors = (handler) => {
    return async(event, context) => {
        let result = await handler(event, context);
        if (!process.env.USER_STORE_API_ACCESS_CONTROL_ALLOW_ORIGIN) {
            return result;
        }

        result = result || {}
        result.headers = result.headers || {}

        if (!result.headers.hasOwnProperty('Access-Control-Allow-Headers')) {
            result.headers['Access-Control-Allow-Headers'] = 'Authorization'
        }

        if (!result.headers.hasOwnProperty('Access-Control-Allow-Origin')) {
            result.headers['Access-Control-Allow-Origin'] = process.env.USER_STORE_API_ACCESS_CONTROL_ALLOW_ORIGIN
        }

        return result
    }
}