#!/bin/bash
set -e
STAGE=test$(date +%s%N)
REGION=$(grep "[ ]*region: .*$" serverless.yml | rev | cut -f1 -d ' ' | rev)
if [ -z "$REGION" ]
then
  REGION=us-east-1
fi
USER_STORE_API_SECURED_SERVICE_NAME=$(grep "^service: .*$" serverless.yml | cut -f2 -d ' ')
echo "Service: $USER_STORE_API_SECURED_SERVICE_NAME"
echo "Region: $REGION"
echo "Stage: $STAGE"
#Keep this for later
USER_STORE_API_SECURED_ISSUER_PROD=$USER_STORE_API_SECURED_ISSUER

 
echo "$(date) - *** INSTALLING TOOLS ***"
rm -rd build || true >/dev/null
mkdir build || true >/dev/null
pip install awscli --upgrade --user >/dev/null
npm install >/dev/null
npm install -g node-jose-tools >/dev/null

echo "$(date) - *** RUNNING UNIT TESTS ***"
npm run unit
PID_UNIT=$!

echo "$(date) - *** DEPLOYING TO TEST $STAGE ***"
USER_STORE_API_SECURED_TEST_JWKS_BUCKET_NAME=$(echo "$USER_STORE_API_SECURED_SERVICE_NAME.$STAGE.test.jwks" | tr '[:upper:]' '[:lower:]')
mkdir build/s3
mkdir build/s3/.well-known
jose newkey -s 2048 -t RSA -u sig -K -b > build/s3/.well-known/jwks.json
echo "Creating bucket $USER_STORE_API_SECURED_TEST_JWKS_BUCKET_NAME"
aws s3api create-bucket --bucket $USER_STORE_API_SECURED_TEST_JWKS_BUCKET_NAME --region=$REGION --acl public-read
aws s3 sync build/s3 s3://$USER_STORE_API_SECURED_TEST_JWKS_BUCKET_NAME --region=$REGION --acl public-read
USER_STORE_API_SECURED_ISSUER=https://s3.amazonaws.com/$USER_STORE_API_SECURED_TEST_JWKS_BUCKET_NAME npm run deploy -- --stage $STAGE

echo "$(date) - *** RUNNING INTEGRATION TESTS ***"
USER_STORE_API_SECURED_FUNCTION_URL=$(aws cloudformation --region $REGION describe-stacks --stack-name $USER_STORE_API_SECURED_SERVICE_NAME-$STAGE --query 'Stacks[0].Outputs[?OutputKey==`ServiceEndpoint`].OutputValue' --output text)
USER_STORE_API_SECURED_TEST_URL=$USER_STORE_API_SECURED_FUNCTION_URL USER_STORE_API_SECURED_ISSUER=https://s3.amazonaws.com/$USER_STORE_API_SECURED_TEST_JWKS_BUCKET_NAME npm run integration

#Run the remove and deploy in parallel to speed up deployment
npm run remove -- --stage $STAGE & >/dev/null
PID_REMOVE=$!
aws s3 rb s3://$USER_STORE_API_SECURED_TEST_JWKS_BUCKET_NAME --force --region $REGION & >/dev/null
PID_REMOVE_BUCKET=$!
echo "$(date) - *** DEPLOYING TO PRODUCTION ***"
USER_STORE_API_SECURED_ISSUER=$USER_STORE_API_SECURED_ISSUER_PROD npm run deploy -- --stage production &
PID_DEPLOY=$!

wait $PID_REMOVE
wait $PID_REMOVE_BUCKET
wait $PID_DEPLOY