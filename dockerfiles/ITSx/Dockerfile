FROM debian:jessie

RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  perl \
  hmmer

ADD http://microbiology.se/sw/ITSx_1.0.11.tar.gz /

RUN cd / && tar xvzf ITSx_1.0.11.tar.gz && ln -s ITSx_1.0.11 ITSx

#docker build -t itsx:1.0.11 .
#docker run -ti --rm itsx:1.0.11 /ITSx/ITSx --help

