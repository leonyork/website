const fs = require('fs');

function handler(data, serverless, options) {
    const script = `TEST_URL=${data.ServiceEndpoint} npm run integration`;
    const path = `scripts/generated/`
    const filename = `run-tests.sh`;
    if (!fs.existsSync(path)) {
        fs.mkdirSync(path);
    }

    fs.writeFileSync(`${path}${filename}`, script);
    fs.chmod(`${path}${filename}`, '0755');
}

module.exports = { handler }