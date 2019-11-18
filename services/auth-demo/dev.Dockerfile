ARG NODE_VERSION
FROM node:${NODE_VERSION}-alpine

RUN apk add --no-cache terraform

# Also exposing VSCode debug ports
EXPOSE 3000 9929 9230

WORKDIR /app