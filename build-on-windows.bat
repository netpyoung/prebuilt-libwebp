@ECHO OFF
SETLOCAL

@REM Windows + R
@REM %comspec% /k "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
@REM %comspec% /k "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"

SET ARCH=%1
if "%ARCH%"=="x86" goto valid
if "%ARCH%"=="x64" goto valid
if "%ARCH%"=="ARM" goto valid
echo %%1(%ARCH%) should be x86 or x64
exit /b 1

@REM ---------------------------------------------------------------------------------------------
:valid
SET VERSION=v1.6.0

SET SRC_DIR=%CD%
SET DST_DIR=%SRC_DIR%\output
SET SQLCIPHER_DIR=%SRC_DIR%\libwebp

SET LIB_DIR=%SRC_DIR%\lib\windows
SET ARCH_LIB_DIR=%LIB_DIR%\%ARCH%
SET BUILD_DIR=build\windows

mkdir %ARCH_LIB_DIR%
mkdir %BUILD_DIR%
cd %BUILD_DIR%

@REM ---------------------------------------------------------------------------------------------
@REM  Clone
@REM ---------------------------------------------------------------------------------------------
if not exist libwebp (
    git clone -b %VERSION% --depth 1 https://github.com/webmproject/libwebp.git
)
CD libwebp


@REM ---------------------------------------------------------------------------------------------
@REM  Windows            (%ARCH%)
@REM ---------------------------------------------------------------------------------------------
git checkout -f
git clean -xdf
git clean -Xdf

powershell -ExecutionPolicy Bypass -Command "$content = Get-Content 'Makefile.vc' -Raw; $pattern = '^OUT_LIBS\s*=\s*\$\(LIBWEBPDECODER\)\s*\$\(LIBWEBP\)\s*\$\(LIBSHARPYUV\).*'; $replacement = 'OUT_LIBS = $(LIBWEBPDECODER) $(LIBWEBP) $(LIBSHARPYUV) $(LIBWEBPDEMUX)'; $newContent = [regex]::Replace($content, $pattern, $replacement, [System.Text.RegularExpressions.RegexOptions]::Multiline); Set-Content 'Makefile.vc' $newContent -NoNewline"
type Makefile.vc | findstr OUT_LIBS

nmake /f Makefile.vc CFG=release-dynamic RTLIBCFG=dynamic OBJDIR=output ARCH=%ARCH%



COPY /Y output\release-dynamic\%ARCH%\bin\libwebp.dll %ARCH_LIB_DIR%
COPY /Y output\release-dynamic\%ARCH%\bin\libwebpdecoder.dll %ARCH_LIB_DIR%
COPY /Y output\release-dynamic\%ARCH%\bin\libwebpdemux.dll %ARCH_LIB_DIR%
COPY /Y output\release-dynamic\%ARCH%\bin\libsharpyuv.dll %ARCH_LIB_DIR%


dumpbin /headers %ARCH_LIB_DIR%\libwebp.dll | findstr machine


exit /b