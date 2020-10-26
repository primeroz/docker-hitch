FROM alpine:3.12 as BUILD

# Only update below
ARG HITCH_VERSION=1.6.1

# dependencies
RUN apk --update add bash build-base libev libev-dev automake openssl openssl-dev autoconf curl byacc flex
# get & build
RUN cd /tmp && curl -L https://hitch-tls.org/source/hitch-${HITCH_VERSION}.tar.gz | tar xz 
RUN cd /tmp/hitch* && ./configure --with-rst2man=/bin/true
RUN cd /tmp/hitch* && make && make install
RUN mkdir -p /etc/ssl/hitch
RUN adduser -h /var/lib/hitch -s /sbin/nologin -u 1000 -D hitch

# Cleanup
RUN cd / && \
    rm -rf /tmp/* && \
    apk del git build-base libev-dev automake autoconf openssl-dev flex byacc && \
    rm -rf /var/cache/apk/*

FROM alpine:3.12
MAINTAINER Francesco Ciocchetti <primeroznl@gmail.com>

RUN apk --update --no-cache add bash libev openssl curl
COPY --from=BUILD /usr/local/sbin/hitch /usr/local/sbin/hitch

ADD start.sh /start.sh

ENV HITCH_PEM    /etc/ssl/hitch/combined.pem
ENV HITCH_PARAMS "--backend=[localhost]:80 --frontend=[*]:443"
ENV HITCH_CIPHER EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH

CMD /start.sh
EXPOSE 443
