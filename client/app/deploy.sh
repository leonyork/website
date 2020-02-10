#!/usr/bin/env sh
DEPLOY_FOLDER=./out

set -eux
aws s3 sync $DEPLOY_FOLDER/_next s3://${S3_BUCKET_ID}/_next --region=${AWS_REGION} --size-only --cache-control "max-age=31557600"
aws s3 sync $DEPLOY_FOLDER/fonts s3://${S3_BUCKET_ID}/fonts --region=${AWS_REGION} --size-only --cache-control "max-age=31557600"
aws s3 sync $DEPLOY_FOLDER s3://${S3_BUCKET_ID} --region=${AWS_REGION} --size-only --cache-control "no-store, no-cache, must-revalidate"
aws s3 cp $DEPLOY_FOLDER/index.html s3://${S3_BUCKET_ID}/index.html --region=${AWS_REGION}  --cache-control "no-store, no-cache, must-revalidate"
aws s3 cp $DEPLOY_FOLDER/service-worker.js s3://${S3_BUCKET_ID}/service-worker.js --region=${AWS_REGION}  --cache-control "no-store, no-cache, must-revalidate"
find ./$DEPLOY_FOLDER -type f ! -name '*.*' | while read HTMLFILE; do
    echo copying $HTMLFILE to s3://${S3_BUCKET_ID}/$(basename $HTMLFILE)
    cat $HTMLFILE | aws s3 cp - s3://${S3_BUCKET_ID}/$(basename $HTMLFILE) --region=${AWS_REGION} --content-type "text/html" --cache-control "no-store, no-cache, must-revalidate"
done;
aws s3 sync $DEPLOY_FOLDER s3://${S3_BUCKET_ID} --region=${AWS_REGION} --size-only --delete