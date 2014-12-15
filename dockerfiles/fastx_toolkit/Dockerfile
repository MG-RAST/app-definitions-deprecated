#fastx_toolkit

FROM ubuntu:14.04


# this does not uncompress
ADD http://hannonlab.cshl.edu/fastx_toolkit/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2 /fastx_bin/

RUN cd /fastx_bin/ && \
	tar -xjf fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2 && \
	mv /fastx_bin/bin/* /usr/local/bin/
