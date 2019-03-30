/**
 * From https://medium.com/@didil/serverless-testing-strategies-393bffb0eef8
 */
const kill = require('tree-kill');
const { spawn } = require('child_process');

let slsOfflineProcess;

beforeAll(async() => {
    //Allow sls offline to start
    jest.setTimeout(30000);

    console.log("[Tests Bootstrap] Start");
    await startSlsOffline();
    console.log("[Tests Bootstrap] Done");
});

afterAll(async() => {
    console.log("[Tests Teardown] Start");
    await stopSlsOffline();
    console.log("[Tests Teardown] Done");
});


// Helper functions

async function startSlsOffline() {
    return new Promise((resolve, reject) => {
        let noColorEnv = process.env;
        noColorEnv.FORCE_COLOR = 0;
        slsOfflineProcess = spawn("sls", ["offline", "start"], { env: noColorEnv });
        console.log(`Serverless: Offline started with PID : ${slsOfflineProcess.pid}`);

        slsOfflineProcess.stdout.on('data', (data) => {
            if (data.includes("Offline listening on")) {
                const listeningLogging = data.toString().trim();
                process.env.USER_STORE_API_SECURED_TEST_URL = listeningLogging.match(/(http|https)\:\/\/[a-zA-Z0-9]*\:[0-9]*$/g)[0];
                console.log(`Serverless offline running on ${process.env.USER_STORE_API_SECURED_TEST_URL}`);
                resolve();
            }
            console.log(data.toString());
        });

        slsOfflineProcess.stderr.on('data', (errData) => {
            console.log(`Error starting Serverless Offline:\n${errData}`);
            reject(errData);
        });
    });
}


async function stopSlsOffline() {
    return new Promise((resolve, reject) => {
        kill(slsOfflineProcess.pid, 'SIGINT', (err) => {
            if (err) { reject(err) }
            console.log("Serverless Offline stopped");
            resolve();
        });
    });
}