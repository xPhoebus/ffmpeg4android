#!/bin/sh

ROOT=$PWD
OUTPUT=$ROOT/build.output
SOURCE=$ROOT/build.temp/ffmpeg-4.0.2

NDK=~/Library/Android/sdk/ndk-bundle
SYSROOT=$NDK/platforms/android-26/arch-arm/
TOOLCHAIN=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64
CPU=arm

if [ ! -d build.temp ]; then
    echo make build.temp
    mkdir build.temp
fi

pushd build.temp

if [ ! -d ffmpeg-4.0.2 ]; then
    if [ ! -f ffmpeg-4.0.2.tar.bz2 ]; then
        wget http://ffmpeg.org/releases/ffmpeg-4.0.2.tar.bz2 && tar -xf ffmpeg-4.0.2.tar.bz2
        if [ $? -ne 0 ]; then
            echo Failed to download ffmpeg-4.0.2.tar.bz2
            exit -1
        fi
    fi
fi

if [ ! -d temp ]; then
    mkdir temp
fi

pushd temp

"$SOURCE/configure" --prefix=$OUTPUT                                \
            --enable-cross-compile                                  \
            --cross-prefix=$TOOLCHAIN/bin/arm-linux-androideabi-    \
            --target-os=linux                                       \
            --host-os=linux                                         \
            --arch=$CPU                                             \
            --sysroot=$SYSROOT                                      \
            --enable-shared                                         \
            --disable-static                                        \
            --disable-doc                                           \
            --disable-indevs                                        \
            --disable-bsfs                                          \
            --disable-muxers                                        \
            --enable-nonfree                                        \
            --enable-gpl                                            \
            --disable-symver                                        \

if [ $? -eq 0 ]; then
    make && make install
fi