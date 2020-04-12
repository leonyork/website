FROM node:13.12.0-alpine3.11 AS node

WORKDIR /app

FROM node AS install

COPY package.json .
COPY package-lock.json .

RUN npm install

FROM install AS source
COPY . .

FROM source AS builder

ARG STAGE=dev
ARG REGION=us-east-1
RUN npm run package -- --stage=${STAGE} --region=${REGION}

FROM builder
CMD ["npm", "run", "offline", "--", "--port 3000"]