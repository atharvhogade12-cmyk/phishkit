FROM alpine:latest
LABEL MAINTAINER="https://github.com/ERA/phishkit.git"
WORKDIR /phishkit/
ADD . /phishkit
RUN apk add --no-cache bash ncurses curl unzip wget php 
CMD "./phishkit.sh"