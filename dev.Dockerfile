ARG NODE_VERSION
FROM node:${NODE_VERSION}-alpine

# Run the build script first so that this and the main Dockerfile can share a cached image
COPY scripts/install/build.sh /install.sh
RUN sh /install.sh && rm -rf /install.sh

COPY scripts/install/dev.sh /install.sh
RUN sh /install.sh && rm -rf /install.sh

# Also exposing VSCode debug ports
EXPOSE 3000 9929 9230

WORKDIR /app