# diamond

FROM ubuntu:14.10
RUN apt-get update && apt-get install -y build-essential libboost-all-dev
ADD https://github.com/bbuchfink/diamond/archive/v0.7.9.tar.gz /
RUN cd / && \
	tar xzf v0.7.9.tar.gz && \
	cd /diamond-0.7.9/src/ && \
	make && \
	cp /diamond-0.7.9/bin/* /usr/local/bin/




# from binary
#FROM ubuntu:14.04
#RUN apt-get update
#ADD http://www-ab.informatik.uni-tuebingen.de/data/software/diamond/download/public/diamond-bin.tar.gz /
#RUN tar -xzvf diamond-bin.tar.gz ; ln -s /diamond-bin/diamond /usr/local/bin/


# scratch not yet supported by Skyport (needs bash)
# download from http://www-ab.informatik.uni-tuebingen.de/data/software/diamond/download/public/diamond-bin.tar.gz
#FROM scratch
#ADD diamond-bin.tar.gz /
#RUN ln -s /diamond-bin/diamond /usr/local/bin/

#CMD ["/diamond-bin/diamond"]
