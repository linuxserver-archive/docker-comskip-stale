FROM ubuntu:bionic as buildstage
############## build stage ##############

# build variables
ARG FFMPEG_VER="4.0.1"
ARG DEBIAN_FRONTEND="noninteractive"

RUN \
 echo "**** install build packages ****" && \
 apt-get update && \
 apt-get install -y \
	autoconf \
	automake \
	binutils \
	bzip2 \
	curl \
	g++ \
	gcc \
	git \
	libargtable2-dev \
	libtool \
	make \
	pkg-config \
	xz-utils \
	yasm

RUN \
 echo "**** build ffmpeg ****" && \
 mkdir -p \
	/tmp/ffmpeg-src/build && \
 curl -o \
 ffmpeg.tar.xz -L \
	"http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VER}.tar.xz" && \
 tar xf \
 ffmpeg.tar.xz -C \
	/tmp/ffmpeg-src --strip-components=1 && \
 cd /tmp/ffmpeg-src && \
 ./configure \
	--disable-programs \
	--prefix=/tmp/ffmpeg-src/build && \
 make && \
 make install

RUN \
 echo "**** build comskip ****" && \
 git clone https://github.com/erikkaashoek/Comskip.git /tmp/comskip-src && \
 cd /tmp/comskip-src && \
 ./autogen.sh && \
 PKG_CONFIG_PATH=/tmp/ffmpeg-src/build/lib/pkgconfig \
 ./configure \
	--enable-static \
	--prefix=/usr && \
 make && \
 make install

############## runtime stage ##############
FROM alpine

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs"

# copy files from build stage
COPY --from=buildstage /usr/bin/comskip /usr/bin/comskip
