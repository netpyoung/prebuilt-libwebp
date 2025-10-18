#!/usr/bin/env bash
set -e

# android-ndk: https://developer.android.com/ndk/downloads

# [variable]
readonly VERSION=v1.6.0
readonly ROOT=$(pwd)
readonly DIR_SOURCE=${ROOT}/libwebp
readonly DIR_OUTPUT=${ROOT}/lib/android

# [src] libwebp
git clone -b ${VERSION} --depth 1 https://github.com/webmproject/libwebp.git
cd libwebp

##---------------------------------------------------------------------------------------------
## Linux for Android Lib
##---------------------------------------------------------------------------------------------

# 1i: line `1` + `i`nsert
sed --in-place '1i ENABLE_SHARED := 1' Android.mk

ndk-build NDK_PROJECT_PATH=${DIR_SOURCE} APP_BUILD_SCRIPT=${DIR_SOURCE}/Android.mk

#---------------------------------------------------------------------------------------------
mkdir -p ${DIR_OUTPUT}/armeabi_v7a
mkdir -p ${DIR_OUTPUT}/arm64_v8a
mkdir -p ${DIR_OUTPUT}/x86
mkdir -p ${DIR_OUTPUT}/x86_64

cp libs/armeabi-v7a/*.so ${DIR_OUTPUT}/armeabi_v7a
cp libs/arm64-v8a/*.so   ${DIR_OUTPUT}/arm64_v8a
cp libs/x86/*.so         ${DIR_OUTPUT}/x86
cp libs/x86_64/*.so      ${DIR_OUTPUT}/x86_64