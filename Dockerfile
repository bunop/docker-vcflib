#
# VERSION 0.1
# DOCKER-VERSION  27.5.0
# AUTHOR:         Paolo Cozzi <paolo.cozzi@ibba.cnr.it>
# DESCRIPTION:    A container with vcflib software installed
# TO_BUILD:       docker build --rm -t bunop/vcflib:latest .
# TO_RUN:         docker run -ti --rm bunop/vcflib:latest /bin/bash
# TO_TAG:         docker tag bunop/vcflib:latest bunop/vcflib:0.1
#

ARG VCFLIB_VERSION=v1.0.12
FROM debian:12.9-slim

RUN apt-get update && apt-get install -y \
        build-essential \
        cmake \
        git \
        pkg-config && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/src

RUN git clone --recursive https://github.com/vcflib/vcflib.git && \
    cd vcflib && \
    git checkout ${VCFLIB_VERSION}

WORKDIR /usr/local/src/vcflib
