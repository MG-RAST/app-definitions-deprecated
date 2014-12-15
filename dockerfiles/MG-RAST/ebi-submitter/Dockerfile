#ebi-submitter


FROM ubuntu:14.04

RUN apt-get update && apt-get install -y \
	wget libwww-perl libjson-perl

RUN wget https://raw.githubusercontent.com/MG-RAST/ebi-submitter/master/scripts/create_xml.pl && \
	chmod +x create_xml.pl && \
	mv create_xml.pl /usr/local/bin
