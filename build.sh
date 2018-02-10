#!/bin/bash

DOCKER_IMAGE_NAME="cutecare/deepspeech"
IMAGE_VERSION="0.4"

log() {
   now=$(date +"%Y%m%d-%H%M%S")
   echo "$now - $*" >> /var/log/docker-build.log
}

log ">>--------------------->>"

## #####################################################################
## Generate the Dockerfile
## #####################################################################
cat << _EOF_ > Dockerfile
FROM library/ubuntu:artful
MAINTAINER Evgeny Savitsky <evgeny.savitsky@gmail.com>
# Base layer
ENV ARCH=amd64
ENV CROSS_COMPILE=/usr/bin/

# Install required packages
RUN apt-get update && \
    apt-get -y install --no-install-recommends \
      wget build-essential python python-dev python-pip python-setuptools \
      lzma git cmake libboost-all-dev libbz2-dev liblzma-dev libeigen3-dev && \
    pip install wheel && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME /work

# Install DeepSpeech and deps
RUN cd /work && git clone -b cutecare https://github.com/cutecare/DeepSpeech.git && \
    pip install -r DeepSpeech/requirements.txt && \
    python DeepSpeech/util/taskcluster.py --target DeepSpeech/native_client

# Install KenLM to produce language model
RUN cd /work/DeepSpeech && \
    wget http://kheafield.com/code/kenlm.tar.gz && \
    tar xfvz kenlm.tar.gz && \
    mkdir -p kenlm/build && \
    cd kenlm/build && \
    cmake .. && \
    make -j 4

_EOF_

## #####################################################################
## Build the Docker image, tag and push to https://hub.docker.com/
## #####################################################################
log "Building $DOCKER_IMAGE_NAME"
## Force-pull the base image
docker pull library/ubuntu:artful
docker build -t $DOCKER_IMAGE_NAME:$IMAGE_VERSION .
log "Pushing $DOCKER_IMAGE_NAME:$IMAGE_VERSION"
docker push $DOCKER_IMAGE_NAME:$IMAGE_VERSION
log "Tagging $DOCKER_IMAGE_NAME:$IMAGE_VERSION with latest"
docker tag $DOCKER_IMAGE_NAME:$IMAGE_VERSION $DOCKER_IMAGE_NAME:latest
log "Pushing $DOCKER_IMAGE_NAME:latest"
docker push $DOCKER_IMAGE_NAME:latest

log ">>--------------------->>"
