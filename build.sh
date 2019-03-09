
STAGE=test$(date +%s%N) 
pip install awscli --upgrade --user 
npm install 
#Serverless seems to not always run the post-deploy hooks to create the script, so just keep retrying in here
rm scripts/generated/run-tests.sh
while [ ! -f scripts/generated/run-tests.sh ]
do
  npm run deploy -- --stage $STAGE 
done
scripts/generated/run-tests.sh
npm run remove -- --stage $STAGE 
npm run deploy -- --stage production