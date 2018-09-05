#!/bin/sh


ROOT=$PWD
OUTPUT=$ROOT/build.output

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

cp -r $ROOT/patches/* .

function make_ffmpeg() {
    ./configure --prefix=$OUTPUT/$ARCH                                  \
                --enable-cross-compile                                  \
                --cross-prefix=$CROSS_PREFIX                            \
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
        make clean
        make -j 8 && make install
    fi
}


NDK=~/Library/Android/sdk/ndk-bundle

SYSROOT=$NDK/platforms/android-27/arch-arm/
#如果是 linux，则 darwin-x86_64 改为 linux-x86_64, 没有环境，未验证
TOOLCHAIN=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64
CROSS_PREFIX=$TOOLCHAIN/bin/arm-linux-androideabi-

ARCH=armeabi-v7a
CPU=arm9

make_ffmpeg


# SYSROOT=$NDK/platforms/android-24/arch-arm64/
# TOOLCHAIN=$NDK/toolchains/aarch64-linux-android-4.9/prebuilt/darwin-x86_64
# CROSS_PREFIX=$TOOLCHAIN/bin/aarch64-linux-android-


# ARCH=arm64-v8a
# CPU=arm

# make_ffmpeg

# exit



NDK=~/Library/Android/sdk/ndk-bundle
SYSROOT=$NDK/platforms/android-26/arch-x86/

#如果是 linux，则 darwin-x86_64 改为 linux-x86_64, 没有环境，未验证
TOOLCHAIN=$NDK/toolchains/x86-4.9/prebuilt/darwin-x86_64
CROSS_PREFIX=$TOOLCHAIN/bin/i686-linux-android-
CFLAGS="-I$NDK/sysroot/usr/include -I$NDK/sysroot/usr/include/i686-linux-android"


ARCH=x86
CPU=x86

make_ffmpeg

SYSROOT=$NDK/platforms/android-26/arch-x86_64/
TOOLCHAIN=$NDK/toolchains/x86_64-4.9/prebuilt/darwin-x86_64
CROSS_PREFIX=$TOOLCHAIN/bin/x86_64-linux-android-

ARCH=x86_64
CPU=x86_64

make_ffmpeg