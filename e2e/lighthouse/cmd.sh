#!/usr/bin/env sh

if [ -z "${MIN_PERFORMANCE_SCORE}" ]; then
  MIN_PERFORMANCE_SCORE=0
fi
if [ -z "${MIN_PWA_SCORE}" ]; then
  MIN_PWA_SCORE=0
fi
if [ -z "${MIN_ACCESIBILITY_SCORE}" ]; then
  MIN_ACCESIBILITY_SCORE=0
fi
if [ -z "${MIN_BEST_PRACTICES_SCORE}" ]; then
  MIN_BEST_PRACTICES_SCORE=0
fi
if [ -z "${MIN_SEO_SCORE}" ]; then
  MIN_SEO_SCORE=0
fi

# Allow running on multiple URLs by splitting the env variable with commas
echo $URLS | tr , '\n' | xargs -I % sh -c 'lighthouse-ci % \
    --performance=$MIN_PERFORMANCE_SCORE \
    --pwa=$MIN_PWA_SCORE \
    --accessibility=$MIN_ACCESIBILITY_SCORE \
    --best-practices=$MIN_BEST_PRACTICES_SCORE \
    --seo=$MIN_SEO_SCORE \
    || exit 255' || exit 1