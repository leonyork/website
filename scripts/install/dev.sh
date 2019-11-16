#!/usr/bin/env sh
# Installs all the packages required for devloping on the project - used by Dockerfiles
# Assumes that build.sh has been run - these are the extra packages for development
apk add --no-cache git py-pip python2-dev openssl-dev curl docker
rm -fR /var/cache/apk/* 

pip install docker-compose