FROM node:13.8.0-alpine AS jose

WORKDIR /app

RUN npm install -g node-jose-tools

FROM jose AS builder

RUN mkdir .well-known && jose newkey -s 2048 -t RSA -u sig -K -b > .well-known/jwks.json

USER dynamodblocal

ENV AWS_ACCESS_KEY_ID=dummy
ENV AWS_SECRET_ACCESS_KEY=dummy
ARG TABLE_NAME=auth-demo-users-dev

FROM nginx:1.17.8-alpine

RUN \
  rm -rf /usr/share/nginx/html/* && \
  echo "server { \
    listen       80; \
    server_name  jwks; \
    location / { \
        root   /usr/share/nginx/html/; \
        add_header  Cache-Control \"no-store, no-cache, must-revalidate\"; \
    } \
  }" > /etc/nginx/conf.d/default.conf

COPY --chown=nginx:nginx --from=builder /app /usr/share/nginx/html/