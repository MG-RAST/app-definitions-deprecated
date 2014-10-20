# AWE client

FROM ubuntu:14.04

RUN apt-get update && apt-get install -y \
	golang \
	git \
	bzr \
	make \
	gcc \
	mercurial

ENV GOPATH /gopath/
RUN go get github.com/MG-RAST/AWE/...
