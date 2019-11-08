FROM node:12.13.0-alpine AS node

# Also exposing VSCode debug ports
EXPOSE 8000 9929 9230

RUN \
  apk add --no-cache python make g++ git && \
  apk add vips-dev fftw-dev --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community --repository http://dl-3.alpinelinux.org/alpine/edge/main && \
  rm -fR /var/cache/apk/* && \
  npm install -g yarn

WORKDIR /app

FROM node AS builder

COPY ./package.json .
COPY ./yarn.lock .
RUN yarn install && yarn cache clean
COPY . .

RUN yarn build

#Argument so that you can run a different task (e.g. tests)
ARG COMMAND="yarn run next export"
RUN ${COMMAND}

FROM nginx:1.17.5-alpine

COPY --chown=nginx:nginx --from=builder /app/out /usr/share/nginx/html/