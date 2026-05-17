FROM alpine:latest
LABEL MAINTAINER="https://github.com/atharvhogade12-cmyk/phishkit.git"
WORKDIR /zphisher/
ADD . /zphisher
RUN apk add --no-cache bash ncurses curl unzip wget php 
CMD "./phishkit.sh"