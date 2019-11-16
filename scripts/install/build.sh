#!/usr/bin/env sh
# Installs all the packages required for building the project - used by Dockerfiles
apk add --no-cache autoconf automake bash g++ libtool libc6-compat libjpeg-turbo-dev libpng-dev make nasm python

apk add vips-dev fftw-dev --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community --repository http://dl-3.alpinelinux.org/alpine/edge/main

rm -fR /var/cache/apk/* 

npm install -g yarn