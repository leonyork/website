#!/bin/bash
set -e
STAGE=test$(date +%s%N)
REGION=$(grep "[ ]*region: .*$" serverless.yml | rev | cut -f1 -d ' ' | rev)
if [ -z "$REGION" ]
then
  REGION=us-east-1
fi
SERVICE_NAME=$(grep "^service: .*$" serverless.yml | cut -f2 -d ' ')
echo "Service: $SERVICE_NAME"
echo "Region: $REGION"
echo "Stage: $STAGE"
 
echo "$(date) - *** INSTALLING TOOLS ***"
pip install awscli --upgrade --user >/dev/null
npm install >/dev/null
echo "$(date) - *** RUNNING UNIT TESTS ***"
npm run unit &
PID_UNIT=$!

echo "$(date) - *** DEPLOYING TO TEST $STAGE ***"
npm run deploy -- --stage $STAGE & >/dev/null
PID_TEST_DEPLOY=$!

wait $PID_UNIT
wait $PID_TEST_DEPLOY

echo "$(date) - *** RUNNING INTEGRATION TESTS ***"
FUNCTION_URL=$(aws cloudformation --region $REGION describe-stacks --stack-name $SERVICE_NAME-$STAGE --query 'Stacks[0].Outputs[?OutputKey==`ServiceEndpoint`].OutputValue' --output text)
TEST_URL=$FUNCTION_URL npm run integration

#Run the remove and deploy in parallel to speed up deployment
npm run remove -- --stage $STAGE & >/dev/null
PID_REMOVE=$!
echo "$(date) - *** DEPLOYING TO PRODUCTION ***"
npm run deploy -- --stage production &
PID_DEPLOY=$!

wait $PID_REMOVE
wait $PID_DEPLOY