#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Just-In-Time Compiler (JIT) for the Lua programming language
cd $PACKAGES
git clone https://github.com/LuaJIT/LuaJIT.git
cd LuaJIT
/usr/bin/make -C src \
  DEFAULT_CC=clang \
  CROSS="/Applications/Xcode_15.2.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/" \
  TARGET_FLAGS="-arch $ARCHS -isysroot $SDKROOT" \
  TARGET_SYS=Darwin \
  PREFIX="$DIR/opt" \
  amalg
/usr/bin/make \
  DEFAULT_CC=clang \
  CROSS="/Applications/Xcode_15.2.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/" \
  TARGET_FLAGS="-arch $ARCHS -isysroot $SDKROOT" \
  TARGET_SYS=Darwin \
  PREFIX="$DIR/opt" \
  install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf luajit.tar.xz -C $DIR/opt .