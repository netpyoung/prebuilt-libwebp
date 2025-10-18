#!/usr/bin/env bash
set -e

# [variable]
readonly VERSION=v1.6.0
readonly ROOT=$(pwd)
readonly DIR_SOURCE=${ROOT}/libwebp
readonly DIR_BUILD=${ROOT}/build/macos
readonly DIR_OUTPUT=${ROOT}/lib/macOS

#---------------------------------------------------------------------------------------------
# for Apple©
#---------------------------------------------------------------------------------------------
readonly DEVELOPER=$(xcode-select -print-path)
readonly TOOLCHAIN_BIN="${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin"
readonly ISYSROOT=$(xcrun --sdk macosx --show-sdk-path)

export CC="${TOOLCHAIN_BIN}/clang"
export AR="${TOOLCHAIN_BIN}/ar"
export RANLIB="${TOOLCHAIN_BIN}/ranlib"
export STRIP="${TOOLCHAIN_BIN}/strip"
export LIBTOOL="${TOOLCHAIN_BIN}/libtool"
export NM="${TOOLCHAIN_BIN}/nm"
export LD="${TOOLCHAIN_BIN}/ld"


# [src] libwebp
git clone -b ${VERSION} --depth 1 https://github.com/webmproject/libwebp.git
cd libwebp

##---------------------------------------------------------------------------------------------
## macOS            (arm64)
##---------------------------------------------------------------------------------------------
OUT_LIB_PATHS_webp=""
OUT_LIB_PATHS_webpdecoder=""
OUT_LIB_PATHS_webpdemux=""
OUT_LIB_PATHS_webpmux=""
OUT_LIB_PATHS_sharpyuv=""

readonly MACOS_MIN_SDK_VERSION=10.12
readonly OS_COMPILER="MacOSX"
readonly HOST="arm64-apple-darwin"

export CROSS_TOP="${DEVELOPER}/Platforms/${OS_COMPILER}.platform/Developer"
export CROSS_SDK="${OS_COMPILER}.sdk"
export SYSROOT="${CROSS_TOP}/SDKs/${CROSS_SDK}"
echo "SYSROOT: ${SYSROOT}"

readonly ARCHS="x86_64 arm64"

for ARCH in ${ARCHS}
do
    DIR_BUILD_ARCH="${DIR_BUILD}/${ARCH}"
    DIR_OUTPUT_ARCH="${DIR_OUTPUT}/${ARCH}"

    mkdir -p "$DIR_BUILD_ARCH"
    mkdir -p "$DIR_OUTPUT_ARCH"

    TARGET="${ARCH}-apple-macos"

    CFLAGS=" \
    -arch ${ARCH} \
    -target ${TARGET} \
    -isysroot ${ISYSROOT} \
    -mmacos-version-min=${MACOS_MIN_SDK_VERSION} \
    -I${SYSROOT}/usr/include \
    -L${SYSROOT}/usr/lib \
    -F${SYSROOT}/System/Library/Frameworks \
    "

    ./autogen.sh
    ./configure --prefix="${DIR_BUILD_ARCH}" --enable-everything --disable-static --host="${HOST}" CFLAGS="${CFLAGS}"
    make && make install

    path_libwebp="$(realpath ${DIR_BUILD_ARCH}/lib/libwebp.dylib)"
    path_libwebpdecoder="$(realpath ${DIR_BUILD_ARCH}/lib/libwebpdecoder.dylib)"
    path_libwebpdemux="$(realpath ${DIR_BUILD_ARCH}/lib/libwebpdemux.dylib)"
    path_libwebpmux="$(realpath ${DIR_BUILD_ARCH}/lib/libwebpmux.dylib)"
    path_libsharpyuv="$(realpath ${DIR_BUILD_ARCH}/lib/libsharpyuv.dylib)"

    cp -r "${path_libwebp}"        "${DIR_OUTPUT_ARCH}/webp.bundle"
    cp -r "${path_libwebpdecoder}" "${DIR_OUTPUT_ARCH}/webpdecoder.bundle"
    cp -r "${path_libwebpdemux}"   "${DIR_OUTPUT_ARCH}/webpdemux.bundle"
    cp -r "${path_libwebpmux}"     "${DIR_OUTPUT_ARCH}/webpmux.bundle"
    cp -r "${path_libsharpyuv}"    "${DIR_OUTPUT_ARCH}/sharpyuv.bundle"

    install_name_tool -id @loader_path/webp.bundle            "${DIR_OUTPUT_ARCH}/webp.bundle"
    install_name_tool -id @loader_path/webpdecoder.bundle     "${DIR_OUTPUT_ARCH}/webpdecoder.bundle"
    install_name_tool -id @loader_path/webpdemux.bundle       "${DIR_OUTPUT_ARCH}/webpdemux.bundle"
    install_name_tool -id @loader_path/webpmux.bundle         "${DIR_OUTPUT_ARCH}/webpmux.bundle"
    install_name_tool -id @loader_path/sharpyuv.bundle        "${DIR_OUTPUT_ARCH}/sharpyuv.bundle"

    install_name_tool -change "$path_libwebp" @loader_path/webp.bundle "${DIR_OUTPUT_ARCH}/webpdemux.bundle"
    install_name_tool -change "$path_libwebp" @loader_path/webp.bundle "${DIR_OUTPUT_ARCH}/webpmux.bundle"
    install_name_tool -change "$path_libsharpyuv" @loader_path/sharpyuv.bundle "${DIR_OUTPUT_ARCH}/webp.bundle"
    install_name_tool -change "$path_libsharpyuv" @loader_path/sharpyuv.bundle "${DIR_OUTPUT_ARCH}/webpdemux.bundle"
    install_name_tool -change "$path_libsharpyuv" @loader_path/sharpyuv.bundle "${DIR_OUTPUT_ARCH}/webpmux.bundle"

    otool -L "${DIR_OUTPUT_ARCH}/webp.bundle"
    otool -L "${DIR_OUTPUT_ARCH}/webpdecoder.bundle"
    otool -L "${DIR_OUTPUT_ARCH}/webpdemux.bundle"
    otool -L "${DIR_OUTPUT_ARCH}/webpmux.bundle"
    otool -L "${DIR_OUTPUT_ARCH}/sharpyuv.bundle"

    OUT_LIB_PATHS_webp="${OUT_LIB_PATHS_webp} ${DIR_OUTPUT_ARCH}/webp.bundle"
    OUT_LIB_PATHS_webpdecoder="${OUT_LIB_PATHS_webpdecoder} ${DIR_OUTPUT_ARCH}/webpdecoder.bundle"
    OUT_LIB_PATHS_webpdemux="${OUT_LIB_PATHS_webpdemux} ${DIR_OUTPUT_ARCH}/webpdemux.bundle"
    OUT_LIB_PATHS_webpmux="${OUT_LIB_PATHS_webpmux} ${DIR_OUTPUT_ARCH}/webpmux.bundle"
    OUT_LIB_PATHS_sharpyuv="${OUT_LIB_PATHS_sharpyuv} ${DIR_OUTPUT_ARCH}/sharpyuv.bundle"

    make clean
done

# === LIPO MERGE ===
lipo -create ${OUT_LIB_PATHS_webp}        -output "${DIR_OUTPUT}/webp.bundle"
lipo -create ${OUT_LIB_PATHS_webpdecoder} -output "${DIR_OUTPUT}/webpdecoder.bundle"
lipo -create ${OUT_LIB_PATHS_webpdemux}   -output "${DIR_OUTPUT}/webpdemux.bundle"
lipo -create ${OUT_LIB_PATHS_webpmux}     -output "${DIR_OUTPUT}/webpmux.bundle"
lipo -create ${OUT_LIB_PATHS_sharpyuv}    -output "${DIR_OUTPUT}/sharpyuv.bundle"

# === VERIFY ===
lipo -info "${DIR_OUTPUT}/webp.bundle"
lipo -info "${DIR_OUTPUT}/webpdecoder.bundle"
lipo -info "${DIR_OUTPUT}/webpdemux.bundle"
lipo -info "${DIR_OUTPUT}/webpmux.bundle"
lipo -info "${DIR_OUTPUT}/sharpyuv.bundle"
