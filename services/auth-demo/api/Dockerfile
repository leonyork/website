# https://hub.docker.com/_/node
FROM node:14.4.0-alpine3.12 AS node

WORKDIR /app

FROM node AS install

COPY package.json .
COPY package-lock.json .

RUN npm install

FROM install AS source
COPY . .

FROM source AS builder

ARG USERS_TABLE
ENV USERS_TABLE=${USERS_TABLE}

ARG USER_STORE_API_SECURED_ISSUER
ENV USER_STORE_API_SECURED_ISSUER=${USER_STORE_API_SECURED_ISSUER}

ARG USER_STORE_API_ACCESS_CONTROL_ALLOW_ORIGIN
ENV USER_STORE_API_ACCESS_CONTROL_ALLOW_ORIGIN=${USER_STORE_API_ACCESS_CONTROL_ALLOW_ORIGIN}

ARG STAGE
ARG REGION
RUN npm run package -- --stage=${STAGE} --region=${REGION}

FROM builder
CMD ["npm", "run", "offline", "--", "--port 3003"]