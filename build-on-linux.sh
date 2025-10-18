#!/usr/bin/env bash
set -e

# [variable]
readonly VERSION=v1.6.0
readonly ROOT=$(pwd)
readonly DIR_SOURCE=${ROOT}/libwebp
readonly DIR_OUTPUT=${ROOT}/lib/linux_64
readonly DIR_LIB=${DIR_SOURCE}/.lib

# [src] libwebp
git clone -b ${VERSION} --depth 1 https://github.com/webmproject/libwebp.git
cd libwebp

##---------------------------------------------------------------------------------------------
## Linux            (x86_64)
##---------------------------------------------------------------------------------------------
./autogen.sh
./configure --prefix=${DIR_LIB} --enable-everything --disable-static
make && make install

#---------------------------------------------------------------------------------------------
mkdir -p ${DIR_OUTPUT}
cp .lib/lib/*.so ${DIR_OUTPUT}