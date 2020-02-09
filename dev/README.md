# Dev

Run a dev environment. This mostly runs locally however will create you a [Cognito user pool](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools.html) and its [client](https://docs.aws.amazon.com/cognito/latest/developerguide/user-pool-settings-client-apps.html). It will start on http://localhost:3000 and the user pool will be configured such that you can sign up with any email address without requiring validation.

## Prerequisites

You'll need to have the prerequisites from 
- [the sign-up lambda](cognito-sign-up/README.md#prerequisites)
- [the cognito module](../packages/services/auth-demo/iam/cognito/README.md#prerequisites)

You'll need [make](https://www.gnu.org/software/make/), [docker-compose](https://docs.docker.com/compose/install/) and [docker](https://docs.docker.com/install/) installed.

## Run

```make dev```
