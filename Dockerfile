FROM alpine:3.7

MAINTAINER Sergey Kardashov <krosh961@yandex.ru>

LABEL org.label-schema.name="alpine3.7" \
      org.label-schema.description="This is a micro docker container based on Alpine 3.7" \
      org.label-schema.url="https://hub.docker.com/r/krosh961/alpine3.7-docker/" \
      org.label-schema.vcs-url="https://github.com/krosh961/alpine3.7-docker" 

COPY root/. /

RUN echo "@community http://dl-4.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "@testing http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \

    # read packages and update
    apk update && apk upgrade && \

    # add packages
    apk add ca-certificates rsyslog logrotate runit && \

    # Make info file about this build
    mkdir -p /etc/BUILDS/ && \
    printf "Build of krosh961/alpine3.7-docker, date: %s\n"  `date -u +"%Y-%m-%dT%H:%M:%SZ"` > /etc/BUILDS/alpine-micro && \

    # install extra from github, including replacement for process 0 (init)

    # add extra package for installation
    apk add curl && \
    cd /tmp && \

    # Install utils and init process
    curl -Ls https://github.com/nimmis/docker-utils/archive/master.tar.gz | tar xfz - && \
    ./docker-utils-master/install.sh && \
    rm -Rf ./docker-utils-master && \
    
    # Install backup support
    curl -Ls https://github.com/nimmis/backup/archive/master.tar.gz | tar xfz - && \
    ./backup-master/install.sh all && \
    rm -Rf ./backup-master && \

    # remove extra packages
    apk del curl && \

    # fix container bug for syslog
    sed  -i "s|\*.emerg|\#\*.emerg|" /etc/rsyslog.conf && \
    sed -i 's/$ModLoad imklog/#$ModLoad imklog/' /etc/rsyslog.conf && \
    sed -i 's/$KLogPermitNonKernelFacility on/#$KLogPermitNonKernelFacility on/' /etc/rsyslog.conf && \

    # remove cached info
    rm -rf /var/cache/apk/*

# Expose backup volume
VOLUME /backup

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

# Define default command.
CMD ["/boot.sh"]

