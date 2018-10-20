FROM alpine

ARG VERSION=v0.0.5

ENV SERVER_ADDR 0.0.0.0
ENV SERVER_PORT 8139
ENV DNS_SERVER  8.8.8.8
ENV OBFS_OPTS   tls
ENV FORWARD     127.0.0.1:8388
ENV FAILOVER    www.baidu.com:443

RUN set -ex && \
    apk add --no-cache libev && \
    apk add --no-cache --virtual .build-deps \
      autoconf \
      automake \
      build-base \
      curl \
      libev-dev \
      libtool \
      linux-headers \
      openssl-dev \
      pcre-dev \
      tar && \
    mkdir -p /tmp/simple-obfs && \
    cd /tmp/simple-obfs && \
    curl -sSL https://github.com/shadowsocks/simple-obfs/archive/$VERSION.tar.gz | tar xz --strip 1 && \
    curl -sSL https://github.com/shadowsocks/libcork/archive/simple-obfs.tar.gz | tar xz --strip 1 -C libcork && \
    ./autogen.sh && \
    ./configure --disable-documentation && \
    make install && \
    apk del .build-deps && \
    cd /tmp && rm -rf simple-obfs

EXPOSE $SERVER_PORT

CMD obfs-server --fast-open \
            -a nobody \
            -s $SERVER_ADDR \
            -p $SERVER_PORT \
            -d $DNS_SERVER \
            --obfs $OBFS_OPTS \
            -r $FORWARD
