ARG NODE_VERSION
ARG NGINX_VERSION
FROM node:${NODE_VERSION}-alpine AS node

# Should match dev.Dockerfile so dev env is as close to build env as sensible
COPY scripts/install/build.sh /install.sh
RUN sh /install.sh && rm -rf /install.sh
  
WORKDIR /app

FROM node AS builder

COPY ./package.json .
COPY ./yarn.lock .
RUN yarn install --prod && yarn cache clean
COPY . .

# Stop Tina being loaded in production
# TODO: Move this to a build script
RUN \
  rm pages/_app.js && \
  for i in ./cms/*.production.js; do mv -f $i ./cms/`basename $i .production.js`.js; done; \
  for i in ./cms/auth-demo/*.production.js; do mv -f $i ./cms/auth-demo/`basename $i .production.js`.js; done;

ARG COGNITO_HOST
ENV REACT_APP_COGNITO_HOST=${COGNITO_HOST}
ARG CLIENT_ID
ENV REACT_APP_CLIENT_ID=${CLIENT_ID}
ARG REDIRECT_URL
ENV REACT_APP_REDIRECT_URL=${REDIRECT_URL}
ARG USER_API_URL
ENV REACT_APP_USER_API_URL=${USER_API_URL}

RUN yarn build

FROM builder AS export
RUN yarn run next export

# next outputs /dir/index.js as /dir.html, so making these accessible as /dir
# TODO: Make this work with the deploy
RUN \
  find ./out -type f -name '*.html' ! -name 'index.html' ! -name '404.html' | while read HTMLFILE; do \
    mv $HTMLFILE $(dirname $HTMLFILE)/$(basename $HTMLFILE .html); \
  done;
    

FROM nginx:${NGINX_VERSION}-alpine

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
        default_type 'text/html'; \
    } \
    location ~ \.(jpg|jpeg|gif|pdf|js|css)$ { \
        root   /usr/share/nginx/html; \
        add_header  Cache-Control max-age=31557600; \
    } \
    error_page  404              /404.html; \
  }" > /etc/nginx/conf.d/default.conf

COPY --chown=nginx:nginx --from=export /app/out /usr/share/nginx/html/