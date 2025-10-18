param(
    [string]$ARCH
)

$SRC_DIR = Get-Location

# Validate ARCH
if ($ARCH -cnotin @("x86", "x64", "ARM")) {
    Write-Error "$ARCH should be x86 or x64 or ARM"
    exit 1
}

# ---------------------------------------------------------------------------------------------
# VS_DEV_SHELL
# - github action use : https://github.com/ilammy/msvc-dev-cmd
# ---------------------------------------------------------------------------------------------
#
#$VS_DEV_SHELL = 'C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\Launch-VsDevShell.ps1'
#$HOST_ARCH = "amd64"
#
#switch ($ARCH) {
#    "x86" { 
#        $TARGET_ARCH = "x86"
#    }
#    "x64" { 
#        $TARGET_ARCH = "amd64"
#    }
#    "ARM" { 
#        $TARGET_ARCH = "arm"
#    }
#}
#. $VS_DEV_SHELL -HostArch $HOST_ARCH -Arch $TARGET_ARCH
#Set-Location $SRC_DIR

# ---------------------------------------------------------------------------------------------
# Settings
# ---------------------------------------------------------------------------------------------
$VERSION = "v1.6.0"

$DST_DIR = Join-Path $SRC_DIR "output"
$SQLCIPHER_DIR = Join-Path $SRC_DIR "libwebp"

$LIB_DIR = Join-Path $SRC_DIR "lib\windows"
$ARCH_LIB_DIR = Join-Path $LIB_DIR $ARCH
$BUILD_DIR = Join-Path $SRC_DIR "build\windows"

# Create directories
New-Item -ItemType Directory -Force -Path $ARCH_LIB_DIR, $BUILD_DIR | Out-Null
Set-Location $BUILD_DIR

# ---------------------------------------------------------------------------------------------
# Clone
# ---------------------------------------------------------------------------------------------
if (!(Test-Path "libwebp")) {
    & git clone -b $VERSION --depth 1 https://github.com/webmproject/libwebp.git
}
Set-Location libwebp

# ---------------------------------------------------------------------------------------------
# Windows
# ---------------------------------------------------------------------------------------------
& git checkout -f
& git clean -xdf
& git clean -Xdf

# Modify Makefile.vc
$content = Get-Content 'Makefile.vc' -Raw
$content = Get-Content Makefile.vc -Raw
$newContent = $content.Replace(
    'OUT_LIBS = $(LIBWEBPDECODER) $(LIBWEBP) $(LIBSHARPYUV)',
    'OUT_LIBS = $(LIBWEBPDECODER) $(LIBWEBP) $(LIBSHARPYUV) $(LIBWEBPDEMUX)'
)
Set-Content 'Makefile.vc' $newContent -NoNewline
Get-Content 'Makefile.vc' | Select-String "OUT_LIBS"

& nmake /f Makefile.vc CFG=release-dynamic RTLIBCFG=dynamic OBJDIR=output ARCH=$ARCH

Copy-Item "output\release-dynamic\$ARCH\bin\libwebp.dll" $ARCH_LIB_DIR -Force
Copy-Item "output\release-dynamic\$ARCH\bin\libwebpdecoder.dll" $ARCH_LIB_DIR -Force
Copy-Item "output\release-dynamic\$ARCH\bin\libwebpdemux.dll" $ARCH_LIB_DIR -Force
Copy-Item "output\release-dynamic\$ARCH\bin\libsharpyuv.dll" $ARCH_LIB_DIR -Force

& dumpbin /headers $ARCH_LIB_DIR\libwebp.dll | Select-String "machine"

Set-Location $SRC_DIR