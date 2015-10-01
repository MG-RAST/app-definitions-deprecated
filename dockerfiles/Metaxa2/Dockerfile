
FROM debian:jessie

RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  perl \
  hmmer \ 
  ncbi-blast+ \
  mafft

ADD http://microbiology.se/sw/Metaxa2_2.0.2.tar.gz /
RUN cd / && tar xvzf /Metaxa2_2.0.2.tar.gz && cd /Metaxa2_2.0.2 && echo -e "yes\n/usr/local/bin/\nyes\n" | ./install_metaxa2


# docker build -t metaxa2:2.0.2 .