# Sign up lambda

Can be attached to cognito as a sign-up trigger to allow a user to sign up without verification. This is useful for dev and testing

## Prerequisites

You'll need an AWS IAM user who can create/update/delete:
 - Lambdas
 - Cloudwatch log groups
 - IAM roles and IAM policies

## Packaging

Run ```make package``` to create a zip file with the Lambda source under ```./.serverless```