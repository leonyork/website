#!/bin/bash
set -e
STAGE=test$(date +%s%N) 
echo "$(date) - *** INSTALLING TOOLS ***"
pip install awscli --upgrade --user >/dev/null
npm install >/dev/null
echo "$(date) - *** RUNNING UNIT TESTS ***"
npm run unit
#Serverless seems to not always run the post-deploy hooks to create the script, so just keep retrying in here
rm scripts/generated/run-tests.sh || true
while [ ! -f scripts/generated/run-tests.sh ]
do
  echo "$(date) - *** DEPLOYING TO TEST $STAGE ***"
  npm run deploy -- --stage $STAGE >/dev/null
done
echo "$(date) - *** RUNNING INTEGRATION TESTS ***"
scripts/generated/run-tests.sh
#Run the remove and deploy in parallel to speed up deployment
npm run remove -- --stage $STAGE & >/dev/null
pid_remove=$!
echo "$(date) - *** DEPLOYING TO PRODUCTION ***"
npm run deploy -- --stage production &
pid_deploy=$!

wait $pid_remove
wait $pid_deploypin