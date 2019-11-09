FROM node:12.13.0-alpine AS node

# Also exposing VSCode debug ports
EXPOSE 8000 9929 9230

RUN \
  apk add --no-cache autoconf automake bash g++ git libtool libc6-compat libjpeg-turbo-dev libpng-dev make nasm python && \
  apk add vips-dev fftw-dev --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community --repository http://dl-3.alpinelinux.org/alpine/edge/main && \
  rm -fR /var/cache/apk/* && \
  npm install -g yarn

WORKDIR /app

FROM node AS builder

COPY ./package.json .
COPY ./yarn.lock .
RUN yarn install --prod && yarn cache clean
COPY . .

# Stop Tina being loaded in production
RUN \
  rm pages/_app.js && \
  for i in ./cms/*.production.js; do mv -f $i ./cms/`basename $i .production.js`.js; done;

RUN yarn build

#Argument so that you can run a different task (e.g. tests)
ARG COMMAND="yarn run next export"
RUN ${COMMAND}

FROM nginx:1.17.5-alpine

RUN \
  rm -rf /usr/share/nginx/html/* && \
  echo "server { \
    listen       80; \
    server_name  leonyork-com; \
    gzip on; \
    gzip_min_length 256; \
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript application/vnd.ms-fontobject application/x-font-ttf font/opentype image/svg+xml image/x-icon; \
    location / { \
        root   /usr/share/nginx/html; \
        index  index.html; \
        add_header  Cache-Control \"no-store, no-cache, must-revalidate\"; \
    } \
    location ~ \.(jpg|jpeg|gif|pdf|js|css)$ { \
        root   /usr/share/nginx/html; \
        add_header  Cache-Control max-age=31557600; \
    } \
    error_page  404              /404.html; \
  }" > /etc/nginx/conf.d/default.conf

COPY --chown=nginx:nginx --from=builder /app/out /usr/share/nginx/html/