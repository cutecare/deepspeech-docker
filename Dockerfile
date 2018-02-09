FROM library/ubuntu:artful
MAINTAINER Evgeny Savitsky <evgeny.savitsky@gmail.com>
# Base layer
ENV ARCH=amd64
ENV CROSS_COMPILE=/usr/bin/

# Install required packages
RUN apt-get update &&     apt-get -y install --no-install-recommends       wget build-essential python python-dev python-pip       lzma git cmake libboost-all-dev libbz2-dev liblzma-dev libeigen3-dev &&     apt-get clean &&     rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install DeepSpeech and deps
RUN apt-get update && apt-get -y install python-setuptools && pip install wheel &&     cd /home && git clone -b cutecare https://github.com/cutecare/DeepSpeech.git &&     pip install -r DeepSpeech/requirements.txt &&     python DeepSpeech/util/taskcluster.py --target DeepSpeech/native_client

# Install KenLM to produce language model
RUN cd /home/DeepSpeech &&     wget http://kheafield.com/code/kenlm.tar.gz &&     tar xfvz kenlm.tar.gz &&     mkdir -p kenlm/build &&     cd kenlm/build &&     cmake .. &&     make -j 4

