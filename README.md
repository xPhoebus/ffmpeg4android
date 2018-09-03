1. MacOS 10.13.6 编译 android 的最新版本 ffmpeg, ffmpeg 版本为 ffmpeg-4.0.2.tar.bz2
1. 目前只编译了 ffmpeg，未开始实际使用
1. 编译脚本参见 build.sh，因为没有 linux 环境，对 linux 环境下的配置不了解
1. 编译环境: MacOS 10.13.6, Android Studio 3.1.2
2. NDK 安装目录 ~/Library/Android/sdk/ndk-bundle，使用 android studio 安装，除下面对一些 include 文件的处理，未做特殊配置，因为编译 ffmpeg 时，android studio 已经安装很久，本人真正开始android 开发也不到一年时间，对 android 的开发目前还不是很熟悉
3. 在编译时，configure 成功后，make 时会出现一些头文件找不到的错误，比如 time.h，原因是
$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/lib/gcc/arm-linux-androideabi/4.9.x/include 目录下缺少一些必要的头文件，比如 time.h 等，而且一些文件也是不正确的，比如 stdint.h。经查找，在 $NDK/sysroot/usr/include/ 下找到了相关文件, 通过 configure 设置 --extra-cflags 与 --host-cflags 到 $NDK/sysroot/usr/include，编译也失败，因此把 $NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/lib/gcc/arm-linux-androideabi/4.9.x/include 目录下的文件删除（删除前做下备份），然后再把 $NDK/sysroot/usr/include 下的拷贝过来，再把 include/arm-linux-androideabi 下的 asm 目录拷贝到 include 下，准备完成后，重新 configure， 不能直接 make
4. configure 成功后，make 时找不到 stdarg.h, stddef.h, float.h, stdbool.h 几个文件，经查找，在原 $NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/lib/gcc/arm-linux-androideabi/4.9.x/include 目录下，拷贝过来
5. 然后还需要 configure，不能直接 make
6. configure 成功后，make 报 libavcodec/aaccoder.c 编译错误，分析错误，应该是函数中的局部变量 B0 被其它地方使用了，因不了解编译器的具体细节，简单的把 B0 换成 V_B0，改后的文件参见 patches/libavcodec/aaccoder.c 文件
7. make 继续报错，相关文件为 libavcodec/hevc_mvs.c，还是 B0 标识符的问题，把 xB0 全局替换成 xB0_v, yB0 替换为 yB0_v, B0 替换为 B0_v，修改后的文件参见 patches/libavcodec/hevc_mvs.c
8. 同样的文件还有 libavcodec/opus_pvq.c