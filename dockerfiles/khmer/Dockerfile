FROM ubuntu:14.04

RUN apt-get -y update && apt-get -y install \
	git emacs mercurial less python-matplotlib \
	unzip bzip2 zlib1g-dev ncurses-dev python-dev \
	build-essential libxml-parser-perl curl

RUN git clone git://github.com/ged-lab/khmer.git && \
	cd khmer && \
	git checkout v1.1 && \
	make install && \
	cd .. && \
	rm -rf khmer

RUN git clone git://github.com/ged-lab/screed.git && \
	cd screed && \
	python setup.py install && \
	cd .. && \
	rm -rf screed

RUN echo export PYTHONPATH=/khmer/python >> /root/.bashrc
