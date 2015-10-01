FROM debian:jessie

RUN apt-get update -y && apt-get install -y python 
ADD http://spades.bioinf.spbau.ru/release3.6.0/SPAdes-3.6.0-Linux.tar.gz /tmp/ 
RUN tar xzf /tmp/SPAdes-3.6.0-Linux.tar.gz && \
    mv SPAdes-3.6.0-Linux/bin/* /usr/local/bin/ && \
    mv SPAdes-3.6.0-Linux/share/* /usr/local/share/

