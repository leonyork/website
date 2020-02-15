# Creates an image that can be used for building the client app. Since there are multiple variables (e.g. Cognito urls)
# that are needed for the build, we create a builder image rather than a traditional archive. These variables are passed
# in as environment variables when running the build
FROM leonyork/yarn-front-end-builder:1.0.0-yarn1.21.1-node13.8.0-alpine3.11 AS base
  
WORKDIR /app

FROM base AS install

COPY ./package.json .
COPY ./yarn.lock .
RUN yarn install --prod && yarn cache clean

FROM install AS builder

COPY . .

# Stop Tina being loaded in production
RUN \
  rm pages/_app.js && \
  for i in ./cms/*.production.js; do mv -f $i ./cms/`basename $i .production.js`.js; done; \
  for i in ./cms/auth-demo/*.production.js; do mv -f $i ./cms/auth-demo/`basename $i .production.js`.js; done;

RUN echo $'#!/usr/bin/env sh \n\
yarn build \n\
yarn run next export \n\
find ./out -type f -name '*.html' ! -name 'index.html' ! -name '404.html' | while read HTMLFILE; do \
  mv $HTMLFILE $(dirname $HTMLFILE)/$(basename $HTMLFILE .html); \
done' > /sbin/build && chmod +x /sbin/build

ENTRYPOINT [ "/sbin/build" ]