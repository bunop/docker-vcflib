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
        wget \
        libhts-dev \
        libtabixpp-dev \
        libtabixpp0 \
        libbzip2-dev \
        pybind11-dev \
        python3.11 \
        python3.11-dev \
        pkg-config && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/src

# getting Zig
RUN wget -q https://ziglang.org/download/0.13.0/zig-linux-x86_64-0.13.0.tar.xz \
    && tar xf zig-linux-x86_64-*.tar.xz \
    && rm zig-linux-x86_64-*.tar.xz
ENV PATH="/usr/local/src/zig-linux-x86_64-0.13.0:${PATH}"

# cloning repositories and submodules
RUN git clone --recursive https://github.com/vcflib/vcflib.git && \
    cd vcflib && \
    git checkout ${VCFLIB_VERSION}

WORKDIR /usr/local/src/vcflib

RUN git submodule update --init --recursive

# Configuring, building and installing vcflib
RUN mkdir -p build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DWFA_GITMODULE=ON .. && \
    cmake --build . -- -j 2 && \
    ctest --verbose
