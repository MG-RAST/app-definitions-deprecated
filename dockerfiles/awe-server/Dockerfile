# AWE Server

# Note that AWE Server and AWE Client Dockerfiles are nearly identical. This allows to reuse cached image layers when building the images.
 

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

#Until here AWE Server and AWE Client Dockerfiles are identical. The
# following RUN command is AWE Server specific:

RUN apt-get install -y mongodb-server ; \
	rm -f /usr/sbin/policy-rc.d #do not start mongo db automatically