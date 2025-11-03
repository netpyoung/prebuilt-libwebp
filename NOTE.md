## Windows Arm에서 LIBWEBPDEMUX 빠지는 문제

OUT_LIBS 쪽에 강제로 LIBWEBPDEMUX 넣어서 해결

## 플렛폼별 몇몇 파일들이 빠졌는데 왜?

``` txt
리눅스
libsharpyuv.so
libwebp.so
libwebpdecoder.so
libwebpdemux.so
libwebpmux.so

윈도우
libsharpyuv.dll
libwebp.dll
libwebpdecoder.dll
libwebpdemux.dll
libwebpmux.dll 빠짐 - libwebpmux 기능이 libwebp.dll 안으로 병합됨

맥
libsharpyuv.dylib
libwebp.dylib
libwebpdecoder.dylib
libwebpdemux.dylib
libwebpmux.dylib

안드
libsharpyuv.so 빠짐 - libwebp.so 안에 포함됨
libwebp.so
libwebpdecoder.so
libwebpdemux.so
libwebpmux.so

ios
libsharpyuv.a
libwebp.a
libwebpdecoder.a
libwebpdemux.a
libwebpmux.a 빠짐 - libwebp.a에 정적으로 포함
```

## dll종속성 문제 생길시

- https://github.com/netpyoung/unity.webp/issues/34
- https://github.com/lucasg/Dependencies
- https://www.microsoft.com/en-us/download/details.aspx?id=48145

## actions 디펜던시 예

- https://docs.github.com/en/code-security/dependabot/working-with-dependabot/keeping-your-actions-up-to-date-with-dependabot

## host x86용. 안쓸꺼지만 기록용

x86_64-apple-darwin

## 파워쉘

& 'C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\Launch-VsDevShell.ps1' -HostArch amd64 -Arch amd64
& 'C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\Launch-VsDevShell.ps1' -HostArch amd64 -Arch arm64
& 'C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\Launch-VsDevShell.ps1' -HostArch amd64 -Arch x86
& 'C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\Launch-VsDevShell.ps1' -HostArch amd64 -Arch arm
. 'C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\Launch-VsDevShell.ps1' -HostArch amd64 -Arch amd64
. 'C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\Launch-VsDevShell.ps1' -HostArch amd64 -Arch arm64
. 'C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\Launch-VsDevShell.ps1' -HostArch amd64 -Arch x86
. 'C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\Launch-VsDevShell.ps1' -HostArch amd64 -Arch arm







# emcmake cmake -LH .
# emcmake cmake -LA . | grep WEBP_BUILD

# https://github.com/WebAssembly/wabtd
# https://github.com/WebAssembly/binaryen

# wasm-objdump

# https://docs.unity3d.com/6000.2/Documentation/Manual/webgl-server-configuration-code-samples.html



:{$http_port:80} {
    root * ./
    file_server

	# BROTLI
    @BROTLI_data_br path *.data.br
    header @BROTLI_data_br Content-Encoding br
    header @BROTLI_data_br Content-Type application/octet-stream

    @BROTLI_js_br path *.js.br
    header @BROTLI_js_br Content-Encoding br
    header @BROTLI_js_br Content-Type application/javascript

    @BROTLI_wasm_br path *.wasm.br
    header @BROTLI_wasm_br Content-Encoding br
    header @BROTLI_wasm_br Content-Type application/wasm

	# GZIP
    @GZIP_data_gz path *.data.gz
    header @GZIP_data_gz Content-Encoding gzip
    header @GZIP_data_gz Content-Type application/octet-stream

    @GZIP_js_gz path *.js.gz
    header @GZIP_js_gz Content-Encoding gzip
    header @GZIP_js_gz Content-Type application/javascript

    @GZIP_wasm_gz path *.wasm.gz
    header @GZIP_wasm_gz Content-Encoding gzip
    header @GZIP_wasm_gz Content-Type application/wasm
}


# aws 에서는 --content-encoding br --content-type application/wasm

# aws s3 cp Build_1.js.gz s3://mybucket/Build_1.js.gz \
#   --content-encoding gzip \
#   --content-type application/javascript
# HTTP Response Header "Content-Type" configured incorrectly on the server for file Build/Build_c.wasm.br , should be "application/wasm". Startup time performance will suffer.

# cmd /c "set http_port=3000 && caddy run"