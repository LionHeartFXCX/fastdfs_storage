FROM ubuntu

MAINTAINER LionHeart <LionHeart_fxc@163.com>

ENV FASTDFS_PATH=/fastDFS 
ENV FASTDFS_BASE_PATH=/data
ENV NGINX_VERSION=1.8.1
ENV PCRE_VERSION=8.37
ENV ZLIB_VERSION=1.2.8
ENV OPENSSL_VERSION=1.0.2f

RUN apt-get update
RUN apt-get install -y g++
RUN apt-get install -y gcc
RUN apt-get install -y git
RUN apt-get install -y make
RUN apt-get install -y wget

RUN mkdir -p ${FASTDFS_PATH}/libfastcommon
RUN mkdir -p ${FASTDFS_PATH}/fastdfs
RUN mkdir -p ${FASTDFS_PATH}/nginx
RUN mkdir -p ${FASTDFS_PATH}/nginx_module
RUN mkdir -p ${FASTDFS_PATH}/download
RUN mkdir ${FASTDFS_BASE_PATH}
RUN ln -s ${FASTDFS_BASE_PATH} ${FASTDFS_BASE_PATH}/M00

RUN git clone https://github.com/happyfish100/libfastcommon.git ${FASTDFS_PATH}/libfastcommon
RUN git clone https://github.com/happyfish100/fastdfs.git ${FASTDFS_PATH}/fastdfs
RUN git clone https://github.com/happyfish100/fastdfs-nginx-module.git ${FASTDFS_PATH}/nginx_module 
RUN wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -P ${FASTDFS_PATH}/nginx 
RUN wget "http://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" -P ${FASTDFS_PATH}/download 
RUN wget "ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${PCRE_VERSION}.tar.gz" -P ${FASTDFS_PATH}/download 
RUN wget "http://zlib.net/zlib-${ZLIB_VERSION}.tar.gz" -P ${FASTDFS_PATH}/download 
RUN tar zxvf ${FASTDFS_PATH}/nginx/nginx-${NGINX_VERSION}.tar.gz -C ${FASTDFS_PATH}/nginx 
RUN tar zxvf ${FASTDFS_PATH}/download/openssl-${OPENSSL_VERSION}.tar.gz -C ${FASTDFS_PATH}/download 
RUN tar zxvf ${FASTDFS_PATH}/download/pcre-${PCRE_VERSION}.tar.gz -C ${FASTDFS_PATH}/download 
RUN tar zxvf ${FASTDFS_PATH}/download/zlib-${ZLIB_VERSION}.tar.gz -C ${FASTDFS_PATH}/download

WORKDIR ${FASTDFS_PATH}/libfastcommon

RUN ["/bin/bash", "-c", "./make.sh"]
RUN ["/bin/bash", "-c", "./make.sh install"]

WORKDIR ${FASTDFS_PATH}/fastdfs

RUN ["/bin/bash", "-c", "./make.sh"]
RUN ["/bin/bash", "-c", "./make.sh install"]

WORKDIR ${FASTDFS_PATH}/nginx/nginx-${NGINX_VERSION}

RUN ./configure --with-pcre=${FASTDFS_PATH}/download/pcre-${PCRE_VERSION} \
--with-zlib=${FASTDFS_PATH}/download/zlib-${ZLIB_VERSION} \
--with-openssl=${FASTDFS_PATH}/download/openssl-${OPENSSL_VERSION} \
--with-http_ssl_module \
--add-module=${FASTDFS_PATH}/nginx_module/src

RUN make
RUN make install

EXPOSE 23000 80