#!/usr/bin/env sh
set -eux
aws s3 rm s3://${S3_BUCKET_ID} --recursive --region=${AWS_REGION} 