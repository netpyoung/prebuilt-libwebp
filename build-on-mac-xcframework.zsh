#!/usr/bin/env zsh
set -e

# [variable]
readonly VERSION=v1.6.0
readonly ROOT=$(pwd)
readonly DIR_SOURCE=${ROOT}/libwebp
readonly DIR_BUILD=${ROOT}/build/macos_xcframework
readonly DIR_OUTPUT=${ROOT}/lib/macOS_xcframework

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
## macOS            (xcframework)
##---------------------------------------------------------------------------------------------
readonly HOST="arm-apple-darwin"

OS_COMPILER_LST=(
iPhoneOS
iPhoneSimulator
AppleTVOS
AppleTVSimulator
)

MIN_SDK_VERSION_LST=(
-mios-version-min=12.0
-mios-simulator-version-min=12.0
-mtvos-version-min=13.0
-mtvos-simulator-version-min=13.0
)

sh autogen.sh


for ((i=1; i<=${#OS_COMPILER_LST}; ++i))
do
    OS_COMPILER=${OS_COMPILER_LST[i]}
    MIN_SDK_VERSION=${MIN_SDK_VERSION_LST[i]}
    PREFIX="${DIR_BUILD}/${OS_COMPILER}"

    export CROSS_TOP="${DEVELOPER}/Platforms/${OS_COMPILER}.platform/Developer"
    export CROSS_SDK="${OS_COMPILER}.sdk"
    export SYSROOT="${CROSS_TOP}/SDKs/${CROSS_SDK}"

    echo "##---------------------------------------------------------------------------------------------"
    echo "# $OS_COMPILER : $MIN_SDK_VERSION"
    echo "# SYSROOT: ${SYSROOT}"
    echo "##---------------------------------------------------------------------------------------------"
    
    CFLAGS="\
-arch arm64 \
-isysroot ${SYSROOT} \
${MIN_SDK_VERSION} \
-pipe \
-O3 \
-DNDEBUG
"
    BUILD=$(${DIR_SOURCE}/config.guess)
    #set -x # for debugging
    ./configure \
        --host=${HOST} \
        --prefix=${PREFIX} \
        --build=${BUILD} \
        --disable-shared --enable-static \
        --enable-libwebpdecoder --enable-swap-16bit-csp \
        --enable-libwebpmux \
        CFLAGS="${CFLAGS}"
    #set +x # for debugging
    make clean
    make V=0 -C sharpyuv install
    make V=0 -C src install
done

#---------------------------------------------------------------------------------------------
# XCFramework
# iOS (arm64, arm64(simulator))
# tvOS (arm64, arm64(simulator))
#---------------------------------------------------------------------------------------------
echo "=================================== XCFramework iOS/tvOS (arm64, arm64(simulator))"

mkdir -p ${DIR_OUTPUT}


xcodebuild -create-xcframework \
  -library ${DIR_BUILD}/iPhoneOS/lib/libwebp.a \
  -library ${DIR_BUILD}/iPhoneSimulator/lib/libwebp.a \
  -library ${DIR_BUILD}/AppleTVSimulator/lib/libwebp.a \
  -library ${DIR_BUILD}/AppleTVOS/lib/libwebp.a \
  -output ${DIR_OUTPUT}/libwebp.xcframework
xcodebuild -create-xcframework \
  -library ${DIR_BUILD}/iPhoneOS/lib/libsharpyuv.a \
  -library ${DIR_BUILD}/iPhoneSimulator/lib/libsharpyuv.a \
  -library ${DIR_BUILD}/AppleTVSimulator/lib/libsharpyuv.a \
  -library ${DIR_BUILD}/AppleTVOS/lib/libsharpyuv.a \
  -output ${DIR_OUTPUT}/libsharpyuv.xcframework
xcodebuild -create-xcframework \
  -library ${DIR_BUILD}/iPhoneOS/lib/libwebpdecoder.a \
  -library ${DIR_BUILD}/iPhoneSimulator/lib/libwebpdecoder.a \
  -library ${DIR_BUILD}/AppleTVSimulator/lib/libwebpdecoder.a \
  -library ${DIR_BUILD}/AppleTVOS/lib/libwebpdecoder.a \
  -output ${DIR_OUTPUT}/libwebpdecoder.xcframework
xcodebuild -create-xcframework \
  -library ${DIR_BUILD}/iPhoneOS/lib/libwebpdemux.a \
  -library ${DIR_BUILD}/iPhoneSimulator/lib/libwebpdemux.a \
  -library ${DIR_BUILD}/AppleTVSimulator/lib/libwebpdemux.a \
  -library ${DIR_BUILD}/AppleTVOS/lib/libwebpdemux.a \
  -output ${DIR_OUTPUT}/libwebpdemux.xcframework
xcodebuild -create-xcframework \
  -library ${DIR_BUILD}/iPhoneOS/lib/libwebpmux.a \
  -library ${DIR_BUILD}/iPhoneSimulator/lib/libwebpmux.a \
  -library ${DIR_BUILD}/AppleTVSimulator/lib/libwebpmux.a \
  -library ${DIR_BUILD}/AppleTVOS/lib/libwebpmux.a \
  -output ${DIR_OUTPUT}/libwebpmux.xcframework

plutil -p ${DIR_OUTPUT}/libwebp.xcframework/Info.plist
plutil -p ${DIR_OUTPUT}/libsharpyuv.xcframework/Info.plist
plutil -p ${DIR_OUTPUT}/libwebpdecoder.xcframework/Info.plist
plutil -p ${DIR_OUTPUT}/libwebpdemux.xcframework/Info.plist
plutil -p ${DIR_OUTPUT}/libwebpmux.xcframework/Info.plist