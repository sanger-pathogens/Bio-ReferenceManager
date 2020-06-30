FROM ubuntu:20.04

ARG TAG=2020.06.30.12.05.53.115
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -yq \
      dos2unix \
      wget \
      rsync \
      gzip \
      python3 \ 
      python3-setuptools \
      python3-pip \
      cpanminus \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN pip3 install pyfastaq


#fastaq
#smalt
#bwa
#bowtie2
#samtools
#Picard


RUN cpanm --notest https://github.com/sanger-pathogens/Bio-ReferenceManager/releases/download/v${TAG}/Bio-ReferenceManager-${TAG}.tar.gz

ARG SMALT_VERSION=0.7.4
ARG SMALT_NAME="smalt-${SMALT_VERSION}"
ARG SMALT_ARCHIVE="${SMALT_NAME}.tgz"
ARG SMALT_URL="ftp://ftp.sanger.ac.uk/pub/resources/software/smalt/${SMALT_ARCHIVE}"

RUN wget --progress=dot:giga "${SMALT_URL}" -O - | tar xf - -C /opt

