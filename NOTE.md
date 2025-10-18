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