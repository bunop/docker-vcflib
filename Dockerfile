#
# VERSION 0.1
# DOCKER-VERSION  27.5.0
# AUTHOR:         Paolo Cozzi <paolo.cozzi@ibba.cnr.it>
# DESCRIPTION:    A container with vcflib software installed
# TO_BUILD:       docker build --rm -t bunop/vcflib:latest .
# TO_RUN:         docker run -ti --rm bunop/vcflib:latest /bin/bash
# TO_TAG:         docker tag bunop/vcflib:latest bunop/vcflib:0.1
#

FROM debian:12.9-slim

RUN apt-get update && apt-get install -y \
        build-essential \
        cmake \
        autoconf \
        automake \
        pkg-config \
        git \
        wget \
        python3 \
        python3-dev \
        pybind11-dev \
        perl \
        libpython3-dev \
        libhts-dev \
        libtabixpp-dev \
        libtabixpp0 \
        libbz2-dev \
        liblzma-dev \
        zlib1g-dev \
        libcurl4-gnutls-dev \
        libssl-dev \
        libdeflate-dev \
        pandoc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# setting the working directory
WORKDIR /usr/local/src

# setting the environment variable for htslib version
ARG HTSLIB_VERSION
ENV HTSLIB_VERSION=${HTSLIB_VERSION:-1.21}

# installing htslib
RUN git clone --recursive https://github.com/samtools/htslib.git && \
    cd htslib && \
    git checkout ${HTSLIB_VERSION} && \
    autoreconf -i && \
    ./configure && \
    make -j $(nproc) && \
    make install

# Installing Zig
RUN wget -q https://ziglang.org/download/0.13.0/zig-linux-x86_64-0.13.0.tar.xz && \
    tar xf zig-linux-x86_64-*.tar.xz && \
    ./zig-linux-x86_64-*/zig version
ENV PATH="/usr/local/src/zig-linux-x86_64-0.13.0:${PATH}"

# setting the environment variable for vcflib version
ARG VCFLIB_VERSION
ENV VCFLIB_VERSION=${VCFLIB_VERSION:-v1.0.12}

# cloning repositories and submodules
RUN git clone --recursive https://github.com/vcflib/vcflib.git && \
    cd vcflib && \
    git checkout ${VCFLIB_VERSION}

# setting the working directory for vcflib
WORKDIR /usr/local/src/vcflib

# Updating submodules WFA2-lib and simde
RUN git submodule update --init --recursive --progress

# Configuring, building and installing vcflib
RUN mkdir -p build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DWFA_GITMODULE=ON .. && \
    cmake --build . -- -j $(nproc) && \
    ctest . --output-on-failure && \
    cmake --install . && \
    cp -a vcfwave /usr/local/bin/
