FROM ubuntu:20.04

ARG TAG
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get upgrade -yq \
    && apt-get update \
    && apt-get install -yq \
      dos2unix \
      rsync \
      gzip \
      python3 \ 
      python3-setuptools \
      python3-pip \
      cpanminus
RUN pip3 install pyfastaq


#fastaq
#smalt
#bwa
#bowtie2
#samtools
#Picard


RUN cpanm https://github.com/sanger-pathogens/Bio-AutomatedAnnotation/releases/download/v${TAG}/Bio-AutomatedAnnotation-${TAG}.tar.gz
