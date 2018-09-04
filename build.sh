#!/bin/sh


ROOT=$PWD
OUTPUT=$ROOT/build.output
SOURCE=$ROOT/build.temp/ffmpeg-4.0.2

NDK=~/Library/Android/sdk/ndk-bundle
SYSROOT=$NDK/platforms/android-26/arch-arm/

#如果是 linux，则 darwin-x86_64 改为 linux-x86_64, 没有环境，未验证
TOOLCHAIN=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64



CFLAGS='-I$NDK/sysroot/usr/include -I$NDK/sysroot/usr/include/arm-linux-androideabi'

if [ ! -d build.temp ]; then
    echo make build.temp
    mkdir build.temp
fi

pushd build.temp

if [ ! -d ffmpeg-4.0.2 ]; then
    if [ ! -f ffmpeg-4.0.2.tar.bz2 ]; then
        wget http://ffmpeg.org/releases/ffmpeg-4.0.2.tar.bz2
        if [ $? -ne 0 ]; then
            echo Failed to download ffmpeg-4.0.2.tar.bz2
            exit -1
        fi
    fi

    tar -xf ffmpeg-4.0.2.tar.bz2
fi

pushd ffmpeg-4.0.2

ARCH=arm
CPU=arm9

cp -r $ROOT/patches/* .

./configure --prefix=$OUTPUT                                        \
            --enable-cross-compile                                  \
            --cross-prefix=$TOOLCHAIN/bin/arm-linux-androideabi-    \
            --target-os=android                                     \
            --host-os=darwin                                        \
            --arch=$ARCH                                            \
            --cpu=$CPU                                              \
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
    make -j 8 && make install
fi