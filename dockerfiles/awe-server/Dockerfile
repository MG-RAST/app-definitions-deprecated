FROM ubuntu:14.04

RUN apt-get update && apt-get install -y \
	golang \
	git \
	mongodb-server \
	bzr \
	make \
	gcc \
	mercurial

ENV GOPATH /gopath/
RUN go get github.com/MG-RAST/AWE/...

RUN rm -f /usr/sbin/policy-rc.d #do not start mongo db automatically