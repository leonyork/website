#!/usr/bin/env bash
set -eux

# From https://github.com/flemay/3musketeers/blob/master/scripts/travis.sh
# During a pull request, encrypted parameters are not passed.
# https://docs.travis-ci.com/user/pull-requests/#pull-requests-and-security-restrictions

echo "Working out whether to deploy..."
echo "TRAVIS_PULL_REQUEST: ${TRAVIS_PULL_REQUEST}"
echo "TRAVIS_BRANCH: ${TRAVIS_BRANCH}"

if [ "${TRAVIS_PULL_REQUEST}" != "false" ]; then
  echo "Triggered on Pull Request: ${TRAVIS_PULL_REQUEST}"
  echo "Just validate the deployment config"
  make deploy-validate
elif [ "${TRAVIS_BRANCH}" = "master" ]; then
  echo "Triggered on Commit/Merge/Schedule to branch: ${TRAVIS_BRANCH}"
  echo "Do the deployment"
  make deploy
else
  echo "Error: case not handled"
  exit 1
fi