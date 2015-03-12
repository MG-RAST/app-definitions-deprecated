# MongoDB 2.4.9 - Version compatible with AWE server

FROM ubuntu:14.04

RUN apt-get update && apt-get install -y \
	mongodb-server && \
	rm -f /usr/sbin/policy-rc.d #do not start mongo db automatically
