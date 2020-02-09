#!/usr/bin/env bash
set -eux

# From https://github.com/flemay/3musketeers/blob/master/scripts/travis.sh
# During a pull request, encrypted parameters are not passed.
# https://docs.travis-ci.com/user/pull-requests/#pull-requests-and-security-restrictions

echo "Working out whether to do e2e tests and deploy..."
echo "TRAVIS_PULL_REQUEST: ${TRAVIS_PULL_REQUEST}"
echo "TRAVIS_BRANCH: ${TRAVIS_BRANCH}"

if [ "${TRAVIS_PULL_REQUEST}" != "false" ]; then
  echo "Triggered on Pull Request: ${TRAVIS_PULL_REQUEST}"
  echo "Just validate the deployment config"
  make infra-validate
elif [ "${TRAVIS_BRANCH}" = "master" ]; then
  echo "Triggered on Commit/Merge/Schedule to branch: ${TRAVIS_BRANCH}"
  echo "Do the e2e tests and deployment"
  # Generate a unique name for the e2e deployment so we can run multiple e2e deployments at the same time
  # Also helps workaround https://github.com/terraform-providers/terraform-provider-aws/issues/1721
  STAGE=e2e-$(date +%s%N)
  make STAGE_E2E=$STAGE e2e-deploy
  make e2e
  make e2e-lighthouse
  make STAGE_E2E=$STAGE e2e-destroy
  make infra
  make deploy
else
  echo "Error: case not handled"
  exit 1
fi