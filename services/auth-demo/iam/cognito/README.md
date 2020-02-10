# Cognito

Creates [Cognito user pool](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools.html) and its [client](https://docs.aws.amazon.com/cognito/latest/developerguide/user-pool-settings-client-apps.html) with a [domain](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-assign-domain.html) that can be used with [OAuth2 implicit flow](https://oauth.net/2/grant-types/implicit/).

## Prerequisites

Requires an AWS IAM user with permission to create/update/delete:
- a Cognito user pool
- a Cognito user pool client
- a Cognito user pool domain