FROM ubuntu:18.04 AS base

ARG INN_VERSION=2.6.3

# RUN echo ${HOSTNAME} > /etc/hostname && \
#     echo "::1 ${HOSTNAME}" >> /etc/hosts && \
#     echo "127.0.0.1 ${HOSTNAME}" >> /etc/hosts

RUN cp /etc/apt/sources.list /etc/apt/sources.list~ && \
        sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list && \
        apt-get update

RUN apt-get install -y wget \
    curl \
    make \
    pkgconf \
    gcc \
    sendmail \
    libpcre2-dev \
    libgd-dev \
    libgd-perl \
    libparse-mime-perl \
    libemail-mime-perl \
    libmime-tools-perl \
    nano \
    vim \
    checkinstall

RUN apt-get build-dep -y inn2

RUN cd /tmp && \
    curl --remote-name ftp://ftp.isc.org/isc/inn/inn-${INN_VERSION}.tar.gz && \
    tar xzf inn-${INN_VERSION}.tar.gz
    
RUN cd /tmp/inn-${INN_VERSION} && \
    ./configure \
#    --prefix=/opt/inn \
    --sysconfdir=/etc/news \
    --localstatedir=/var/state \
    --with-log-dir=/var/log \
    --with-sendmail=/usr/sbin/sendmail \
    --enable-tagged-hash \
    --with-perl \
    --enable-shared \
    --with-gnu-ld

RUN cd /tmp/inn-${INN_VERSION} && \
    make

COPY ./config/inn.conf /tmp/inn-${INN_VERSION}/site/inn.conf
COPY ./config/inn.conf /tmp/inn-${INN_VERSION}/samples/inn.conf

RUN cd /tmp/inn-${INN_VERSION} && \
    make install && \
    make clean

RUN rm -r /tmp/inn-*