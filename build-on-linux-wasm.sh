#!/usr/bin/env bash
set -e

# sudo apt update && sudo apt upgrade -y
# sudo apt install -y git python3 cmake build-essential
# sudo apt install -y ninja-build # for ninja

# git clone https://github.com/emscripten-core/emsdk.git
# cd emsdk
# ./emsdk install latest
# ./emsdk activate latest
# source ./emsdk_env.sh

# [variable]
readonly VERSION=v1.6.0
readonly ROOT=$(pwd)
readonly DIR_SOURCE=${ROOT}/libwebp
readonly DIR_OUTPUT=${ROOT}/lib/wasm
readonly DIR_LIB=${DIR_SOURCE}/_WORKINGSPACE

# [src] libwebp
git clone -b ${VERSION} --depth 1 https://github.com/webmproject/libwebp.git
cd libwebp

##---------------------------------------------------------------------------------------------
## Linux            (wasm)
##---------------------------------------------------------------------------------------------
CMAKE_COMMON_FLAGS=" \
-DCMAKE_BUILD_TYPE=Release \
-DWEBP_ENABLE_SIMD=OFF \
-DWEBP_BUILD_ANIM_UTILS=OFF \
-DWEBP_BUILD_CWEBP=OFF \
-DWEBP_BUILD_DWEBP=OFF \
-DWEBP_BUILD_GIF2WEBP=OFF \
-DWEBP_BUILD_IMG2WEBP=OFF \
-DWEBP_BUILD_VWEBP=OFF \
-DWEBP_BUILD_WEBPINFO=OFF \
-DWEBP_BUILD_LIBWEBPMUX=ON \
-DWEBP_BUILD_WEBPMUX=OFF \
-DWEBP_BUILD_EXTRAS=ON \
-DWEBP_USE_THREAD=OFF \
"

# ref:
#  - https://docs.unity3d.com/6000.2/Documentation/Manual/webgl-native-plugins-with-emscripten.html
#   - https://docs.unity3d.com/6000.2/Documentation/Manual/web-interacting-browsers-library.html

CMAKE_CC_FLAGS="\
-msimd128 \
-fwasm-exceptions \
-mbulk-memory \
-mnontrapping-fptoint \
-msse4.2 \
-s WASM_BIGINT=1 \
-s SUPPORT_LONGJMP=wasm \
"

# - with ninja
#   - https://ninja-build.org/
#   - https://github.com/ninja-build/ninja
#
# emcmake cmake -B ${DIR_LIB} . -G Ninja ${CMAKE_COMMON_FLAGS} -DCMAKE_C_FLAGS="${CMAKE_CC_FLAGS}" -DCMAKE_CXX_FLAGS="${CMAKE_CC_FLAGS}"
# emmake ninja  -C ${DIR_LIB} -j$(nproc)

#- without ninja
emcmake cmake -B ${DIR_LIB} . ${CMAKE_COMMON_FLAGS} -DCMAKE_C_FLAGS="${CMAKE_CC_FLAGS}" -DCMAKE_CXX_FLAGS="${CMAKE_CC_FLAGS}"
emmake  make  -C ${DIR_LIB} -j$(nproc)

#---------------------------------------------------------------------------------------------
mkdir -p ${DIR_OUTPUT}
cp ${DIR_LIB}/libwebp.a        ${DIR_OUTPUT}
cp ${DIR_LIB}/libwebpdemux.a   ${DIR_OUTPUT}
cp ${DIR_LIB}/libsharpyuv.a    ${DIR_OUTPUT}
cp ${DIR_LIB}/libwebpdecoder.a ${DIR_OUTPUT}
cp ${DIR_LIB}/libwebpmux.a     ${DIR_OUTPUT}