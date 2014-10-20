FROM ubuntu:14.04

RUN apt-get update && apt-get install -y \
	samtools \
	bedtools \
	python \
	git \
	r-base \
	python-pip \
	python-dev

RUN git clone https://github.com/kbase/cap.git
ENV PATH $PATH:/cap/scripts

RUN pip install screed && pip install numpy

RUN R --vanilla --slave < /cap/scripts/install_packages.r

