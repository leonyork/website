#!/usr/bin/env sh
# Installs all the packages required for deploying the project - used by Dockerfiles
apk add --no-cache python py-pip python2-dev openssl-dev curl gcc groff less mailcap musl-dev libffi-dev make docker
rm -fR /var/cache/apk/* 

pip install --upgrade awscli==1.14.5 s3cmd==2.0.1 python-magic docker-compose