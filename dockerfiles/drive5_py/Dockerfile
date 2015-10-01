FROM debian:jessie

RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y python

ADD http://drive5.com/python/python_scripts.tar.gz /

RUN cd /usr/local/bin && tar xzvf /python_scripts.tar.gz

