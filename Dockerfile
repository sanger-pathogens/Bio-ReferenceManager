#
#  From this base-image / starting-point
#
FROM debian:testing

#
#  Authorship
#
MAINTAINER ap13@sanger.ac.uk

RUN apt-get update && apt-get install -y dos2unix python3 python3-setuptools python3-biopython python3-pip git cpanm libdist-zilla-perl libmodule-install-perl
RUN pip3 install pyfastaq

RUN git clone https://github.com/sanger-pathogens/Bio-ReferenceManager.git
RUN cd Bio-ReferenceManager && dzil authordeps | cpanm
RUN cd Bio-ReferenceManager && dzil listdeps | cpanm 
RUN cd Bio-ReferenceManager && dzil install
