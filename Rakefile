require 'zip'
require 'digest/md5'

GIT_ROOT = `git rev-parse --show-toplevel`.strip
VERSION = 'v1.3.2'
LIBWEBP = "libwebp"

desc "default"
task :default do
  sh 'rake -T'
end

## ================================================================================
desc "prepare library_windows"
task :prepare_library_windows do
  build_dir = 'build/windows'
  FileUtils.mkdir_p(build_dir) unless File.directory?(build_dir)
  Dir.chdir(build_dir) do
    sh 'git clone https://github.com/webmproject/libwebp.git'
    Dir.chdir('libwebp') do
      sh "git checkout #{VERSION}"
    end
  end
end


desc "update library_windows_x64"
task :update_library_windows_x64 do
  # Windows + R
  # %comspec% /k "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
  build_dir = 'build/windows'
  lib_dir = "#{GIT_ROOT}/lib/windows"

  Dir.chdir(build_dir) do
    Dir.chdir('libwebp') do
      puts "============== x64"
      sh "git clean -xdf"
      arch_lib_dir = "#{lib_dir}/x64"
      FileUtils.mkdir_p(arch_lib_dir) unless File.directory?(arch_lib_dir)
      sh 'nmake /f Makefile.vc CFG=release-dynamic RTLIBCFG=dynamic OBJDIR=output ARCH=x64'
      cp 'output/release-dynamic/x64/bin/libwebp.dll', arch_lib_dir
      cp 'output/release-dynamic/x64/bin/libwebpdecoder.dll', arch_lib_dir
      cp 'output/release-dynamic/x64/bin/libwebpdemux.dll', arch_lib_dir
    end
  end
end

desc "update library_windows_x86"
task :update_library_windows_x86 do
  # Windows + R
  # %comspec% /k "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
  build_dir = 'build/windows'
  lib_dir = "#{GIT_ROOT}/lib/windows"

  Dir.chdir(build_dir) do
    Dir.chdir('libwebp') do
      puts "============== x86"
      sh "git clean -xdf"
      arch_lib_dir = "#{lib_dir}/x86"
      FileUtils.mkdir_p(arch_lib_dir) unless File.directory?(arch_lib_dir)
      sh 'nmake /f Makefile.vc CFG=release-dynamic RTLIBCFG=dynamic OBJDIR=output ARCH=x86'
      cp 'output/release-dynamic/x86/bin/libwebp.dll', arch_lib_dir
      cp 'output/release-dynamic/x86/bin/libwebpdecoder.dll', arch_lib_dir
      cp 'output/release-dynamic/x86/bin/libwebpdemux.dll', arch_lib_dir
    end
  end
end

desc "update library_windows_arm64"
task :update_library_windows_arm64 do
  # Windows + R
  # %comspec% /k "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
  build_dir = 'build/windows'
  lib_dir = "#{GIT_ROOT}/lib/windows"

  Dir.chdir(build_dir) do
    Dir.chdir('libwebp') do
      puts "============== ARM"
      sh "git clean -xdf"
      arch_lib_dir = "#{lib_dir}/ARM"
      FileUtils.mkdir_p(arch_lib_dir) unless File.directory?(arch_lib_dir)

      data = File.read("Makefile.vc") 
      filtered_data = data.gsub("OUT_LIBS = $(LIBWEBPDECODER) $(LIBWEBP)", "OUT_LIBS = $(LIBWEBPDECODER) $(LIBWEBP) $(LIBWEBPDEMUX)") 
      File.open("Makefile.vc", "w") do |f|
        f.write(filtered_data)
      end

      sh 'nmake /f Makefile.vc CFG=release-dynamic RTLIBCFG=dynamic OBJDIR=output ARCH=ARM'
      cp 'output/release-dynamic/ARM/bin/libwebp.dll', arch_lib_dir
      cp 'output/release-dynamic/ARM/bin/libwebpdecoder.dll', arch_lib_dir
      cp 'output/release-dynamic/ARM/bin/libwebpdemux.dll', arch_lib_dir
    end
  end
end


## ================================================================================
desc "update library_linux"
task :update_library_linux do
  build_dir = 'build/linux'
  lib_dir = "#{GIT_ROOT}/lib/linux_64"

  FileUtils.mkdir_p(build_dir) unless File.directory?(build_dir)
  FileUtils.mkdir_p(lib_dir) unless File.directory?(lib_dir)

  Dir.chdir(build_dir) do
    sh 'git clone https://github.com/webmproject/libwebp.git'
    Dir.chdir('libwebp') do
      sh "git checkout #{VERSION}"
      sh './autogen.sh'
      sh "./configure --prefix=`pwd`/.lib --enable-everything --disable-static"
      sh 'make && make install'

      cp_r '.lib/lib', lib_dir
    end
  end
end


desc "update library_android"
task :update_library_android do
  # android-ndk: https://developer.android.com/ndk/downloads
  ANDROID_MK = 'Android.mk'

  build_dir = 'build/android'
  lib_armeabi_v7a_dir = "#{GIT_ROOT}/lib/android/armeabi-v7a"
  lib_x86_dir = "#{GIT_ROOT}/lib/android/x86"
  lib_x86_64_dir = "#{GIT_ROOT}/lib/android/x86_64"
  lib_arm64_v8a_dir  = "#{GIT_ROOT}/lib/android/arm64-v8a"

  FileUtils.mkdir_p(build_dir) unless File.directory?(build_dir)
  FileUtils.mkdir_p(lib_x86_dir) unless File.directory?(lib_x86_dir)
  FileUtils.mkdir_p(lib_armeabi_v7a_dir) unless File.directory?(lib_armeabi_v7a_dir)
  FileUtils.mkdir_p(lib_arm64_v8a_dir) unless File.directory?(lib_arm64_v8a_dir)
  FileUtils.mkdir_p(lib_x86_64_dir) unless File.directory?(lib_x86_64_dir)

  Dir.chdir(build_dir) do
    puts '==== Clone webp'
    sh 'git clone https://github.com/webmproject/libwebp.git'

    Dir.chdir('libwebp') do
      puts '==== checkout'
      sh "git checkout #{VERSION}"

      # to enable build shared library
      File.open(ANDROID_MK, "r") do |orig|
        # File.unlink(ANDROID_MK)
        o = orig.read()
        File.open(ANDROID_MK, "w") do |new|
          new.puts 'ENABLE_SHARED := 1'
          new.write(o)
        end
      end

      puts '==== NDK build'
      # NDK_BUILD_FPATH = "#{Dir.home}/android-ndk-r20/ndk-build"
      sh "ndk-build NDK_PROJECT_PATH=#{Dir.pwd} APP_BUILD_SCRIPT=#{Dir.pwd}/#{ANDROID_MK}"

      ['libwebp.so', 'libwebpdecoder.so', 'libwebpdemux.so', 'libwebpmux.so'].each do |so|
        cp_r "libs/armeabi-v7a/#{so}", lib_armeabi_v7a_dir
        cp_r "libs/arm64-v8a/#{so}", lib_arm64_v8a_dir
        cp_r "libs/x86/#{so}", lib_x86_dir
        cp_r "libs/x86_64/#{so}", lib_x86_64_dir
      end
    end
  end
end


## ================================================================================
desc "update library_macos"
task :update_library_macos do
  BUILD_DIR = "#{Dir.pwd}/build/macos"
  LIB_DIR = "#{GIT_ROOT}/lib/macos_64"

  FileUtils.mkdir_p(BUILD_DIR) unless File.directory?(BUILD_DIR)
  FileUtils.mkdir_p(LIB_DIR) unless File.directory?(LIB_DIR)

  DEVELOPER=`xcode-select -print-path`.strip
  TOOLCHAIN_BIN="#{DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin"
  ENV["CC"] ="#{TOOLCHAIN_BIN}/clang"
  ENV["AR"] ="#{TOOLCHAIN_BIN}/ar"
  ENV["RANLIB"] ="#{TOOLCHAIN_BIN}/ranlib"
  ENV["STRIP"] ="#{TOOLCHAIN_BIN}/strip"
  ENV["LIBTOOL"] ="#{TOOLCHAIN_BIN}/libtool"
  ENV["NM"] ="#{TOOLCHAIN_BIN}/nm"
  ENV["LD"] ="#{TOOLCHAIN_BIN}/ld"

  OUT_LIB_PATHS_webp = ''
  OUT_LIB_PATHS_webpdecoder = ''
  OUT_LIB_PATHS_webpdemux = ''
  OUT_LIB_PATHS_webpmux = ''

  HOST="aarch64-apple-darwin"
  ISYSROOT=`xcrun --sdk macosx --show-sdk-path`

  Dir.chdir(BUILD_DIR) do
    sh 'git clone https://github.com/webmproject/libwebp.git'
    Dir.chdir('libwebp') do
      sh "git checkout #{VERSION}"

      for ARCH in ['x86_64', 'arm64']
        BUILD_ARCH_DIR="#{BUILD_DIR}/#{ARCH}"
        LIB_ARCH_DIR="#{LIB_DIR}/#{ARCH}"
        sh "mkdir -p #{BUILD_ARCH_DIR}"
        sh "mkdir -p #{LIB_ARCH_DIR}"

        TARGET="#{ARCH}-apple-macos"
        CFLAGS = ""\
          " -arch #{ARCH}"  \
          " -target #{TARGET}" \
          " -isysroot #{ISYSROOT}" \
          " -mmacos-version-min=10.12" \
          " -I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include" \
          " -F/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks"
        sh './autogen.sh'
        sh "./configure --prefix=#{BUILD_ARCH_DIR} --enable-everything --disable-static --host=#{HOST} CFLAGS='#{CFLAGS}'"
        sh 'make && make install'

        path_libwebp        = `realpath #{BUILD_ARCH_DIR}/lib/libwebp.dylib`.strip
        path_libwebpdecoder = `realpath #{BUILD_ARCH_DIR}/lib/libwebpdecoder.dylib`.strip
        path_libwebpdemux   = `realpath #{BUILD_ARCH_DIR}/lib/libwebpdemux.dylib`.strip
        path_libwebpmux     = `realpath #{BUILD_ARCH_DIR}/lib/libwebpmux.dylib`.strip
    
        sh "cp -r #{path_libwebp}        #{BUILD_ARCH_DIR}/webp.bundle"
        sh "cp -r #{path_libwebpdecoder} #{BUILD_ARCH_DIR}/webpdecoder.bundle"
        sh "cp -r #{path_libwebpdemux}   #{BUILD_ARCH_DIR}/webpdemux.bundle"
        sh "cp -r #{path_libwebpmux}     #{BUILD_ARCH_DIR}/webpmux.bundle"
    
        sh "otool -L #{BUILD_ARCH_DIR}/webp.bundle"
        sh "otool -L #{BUILD_ARCH_DIR}/webpdecoder.bundle"
        sh "otool -L #{BUILD_ARCH_DIR}/webpdemux.bundle"
        sh "otool -L #{BUILD_ARCH_DIR}/webpmux.bundle"
    
        sh "install_name_tool -id @loader_path/webp.bundle            #{BUILD_ARCH_DIR}/webp.bundle"
        sh "install_name_tool -id @loader_path/wewebpdecoderbp.bundle #{BUILD_ARCH_DIR}/webpdecoder.bundle"
        sh "install_name_tool -id @loader_path/webpdemux.bundle       #{BUILD_ARCH_DIR}/webpdemux.bundle"
        sh "install_name_tool -id @loader_path/webpmux.bundle         #{BUILD_ARCH_DIR}/webpmux.bundle"
        sh "install_name_tool -change #{path_libwebp} @loader_path/webp.bundle #{BUILD_ARCH_DIR}/webpdemux.bundle"
        sh "install_name_tool -change #{path_libwebp} @loader_path/webp.bundle #{BUILD_ARCH_DIR}/webpmux.bundle"
    
        sh "otool -L #{BUILD_ARCH_DIR}/webp.bundle"
        sh "otool -L #{BUILD_ARCH_DIR}/webpdecoder.bundle"
        sh "otool -L #{BUILD_ARCH_DIR}/webpdemux.bundle"
        sh "otool -L #{BUILD_ARCH_DIR}/webpmux.bundle"
    
        OUT_LIB_PATHS_webp        += "  #{BUILD_ARCH_DIR}/webp.bundle"
        OUT_LIB_PATHS_webpdecoder += "  #{BUILD_ARCH_DIR}/webpdecoder.bundle"
        OUT_LIB_PATHS_webpdemux   += "  #{BUILD_ARCH_DIR}/webpdemux.bundle"
        OUT_LIB_PATHS_webpmux     += "  #{BUILD_ARCH_DIR}/webpmux.bundle"

        sh 'make clean'
      end
    end
  end
  

  sh "lipo -create #{OUT_LIB_PATHS_webp}        -output #{LIB_DIR}/webp.bundle"
  sh "lipo -create #{OUT_LIB_PATHS_webpdecoder} -output #{LIB_DIR}/webpdecoder.bundle"
  sh "lipo -create #{OUT_LIB_PATHS_webpdemux}   -output #{LIB_DIR}/webpdemux.bundle"
  sh "lipo -create #{OUT_LIB_PATHS_webpmux}     -output #{LIB_DIR}/webpmux.bundle"

  sh "lipo -info #{LIB_DIR}/webp.bundle"
  sh "lipo -info #{LIB_DIR}/webpdecoder.bundle"
  sh "lipo -info #{LIB_DIR}/webpdemux.bundle"
  sh "lipo -info #{LIB_DIR}/webpmux.bundle"
end


desc "update library_ios"
task :update_library_ios do
  build_dir = 'build/ios'
  lib_dir  = "#{GIT_ROOT}/lib/ios"
  lib_simulator_dir  = "#{GIT_ROOT}/lib/ios-simulator"
  sdk_version = `xcodebuild -showsdks | grep iphoneos | sort | tail -n 1 | awk '{print substr($NF, 9)}'`.strip # same as 'iosbuild.sh'

  FileUtils.mkdir_p(build_dir) unless File.directory?(build_dir)
  FileUtils.mkdir_p(lib_dir) unless File.directory?(lib_dir)
  FileUtils.mkdir_p(lib_simulator_dir) unless File.directory?(lib_simulator_dir)
  Dir.chdir(build_dir) do
    sh 'git clone https://github.com/webmproject/libwebp.git'

    Dir.chdir('libwebp') do
      sh "git checkout #{VERSION}"
      sh "./iosbuild.sh"

      # universal static library
      # ['libwebp.a', 'libwebpdecoder.a', 'libwebpdemux.a'].each do |a|
      #   sh "lipo -create -output #{a} iosbuild/iPhoneOS-#{sdk_version}-aarch64/lib/#{a} iosbuild/iPhoneOS-#{sdk_version}-armv7/lib/#{a}"
      #   cp_r a, lib_dir
      # end

      # x64 only
      ['libwebp.a', 'libwebpdecoder.a', 'libwebpdemux.a'].each do |a|
        cp_r "iosbuild/iPhoneOS-#{sdk_version}-aarch64/lib/#{a}", lib_dir
      end

      # simulator static library
      ['libwebp.a', 'libwebpdecoder.a', 'libwebpdemux.a'].each do |a|
        # sh "lipo -create -output #{a} iosbuild/iPhoneSimulator-#{sdk_version}-x86_64/lib/#{a} iosbuild/iPhoneSimulator-#{sdk_version}-i386/lib/#{a}"
        cp_r "iosbuild/iPhoneSimulator-#{sdk_version}-x86_64/lib/#{a}", lib_simulator_dir
      end
    end
  end
end


## ================================================================================
desc "print lib md5"
task :print_lib_md5 do
  Dir.glob("lib/**/*").each do |path|
    next if File.directory?(path)

    md5 = Digest::MD5.hexdigest(IO.read(path))
    puts "#{md5} : #{path}"
  end
end


## ================================================================================
class ZipFileGenerator
  # Usage:
  #   directory_to_zip = "/tmp/input"
  #   output_file = "/tmp/out.zip"
  #   zf = ZipFileGenerator.new(directory_to_zip, output_file)
  #   zf.write()

  # Initialize with the directory to zip and the location of the output archive.
  def initialize(input_dir, output_file)
    @input_dir = input_dir
    @output_file = output_file
  end

  # Zip the input directory.
  def write
    entries = Dir.entries(@input_dir) - %w[. ..]

    ::Zip::File.open(@output_file, create: true) do |zipfile|
      write_entries entries, '', zipfile
    end
  end

  private

  # A helper method to make the recursion work.
  def write_entries(entries, path, zipfile)
    entries.each do |e|
      zipfile_path = path == '' ? e : File.join(path, e)
      disk_file_path = File.join(@input_dir, zipfile_path)

      if File.directory? disk_file_path
        recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
      else
        put_into_archive(disk_file_path, zipfile, zipfile_path)
      end
    end
  end

  def recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
    zipfile.mkdir zipfile_path
    subdir = Dir.entries(disk_file_path) - %w[. ..]
    write_entries subdir, zipfile_path, zipfile
  end

  def put_into_archive(disk_file_path, zipfile, zipfile_path)
    zipfile.add(zipfile_path, disk_file_path)
  end
end


desc "zip library"
task :zip_library do
  zf = ZipFileGenerator.new('lib', 'lib.zip')
  zf.write()
end