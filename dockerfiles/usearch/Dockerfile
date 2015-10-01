
FROM debian:jessie 
#FROM scratch # This works, but is not yet supported by AWE as it requires bash

ADD ./usearch /
ENTRYPOINT ["/usearch"]



# copy usearch binary into the Dockerfile directory
# and build, e.g.: docker build -t usearch:8.1.1756_i86linux32 .
# WARNING: due to the usearch license, if you upload this image to dockerhub or Shock, make sure it is private !
