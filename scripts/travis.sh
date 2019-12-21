#!/usr/bin/env bash
set -eux

# From https://github.com/flemay/3musketeers/blob/master/scripts/travis.sh
# During a pull request, encryoted parameters are not passed.
# https://docs.travis-ci.com/user/pull-requests/#pull-requests-and-security-restrictions

echo "TRAVIS_PULL_REQUEST: ${TRAVIS_PULL_REQUEST}"
echo "TRAVIS_BRANCH: ${TRAVIS_BRANCH}"

if [ "${TRAVIS_PULL_REQUEST}" != "false" ]; then
  echo "Triggered on Pull Request: ${TRAVIS_PULL_REQUEST}"
  make .test
elif [ "${TRAVIS_BRANCH}" = "master" ]; then
  echo "Triggered on Commit/Merge/Schedule to branch: ${TRAVIS_BRANCH}"
  make .test
  make .deploy
else
  echo "Error: case not handled"
  exit 1
fi