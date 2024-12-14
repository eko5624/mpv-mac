#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Just-In-Time Compiler (JIT) for the Lua programming language
cd $PACKAGES
git clone https://github.com/LuaJIT/LuaJIT.git
cd LuaJIT
make -C src \
  CROSS=clang \
  TARGET_FLAGS="-arch x86_64 -isysroot $SDKROOT" \
  TARGET_SYS=Darwin \
  BUILDMODE=static \
  XCFLAGS="-DLUAJIT_ENABLE_GC64 -DLUAJIT_ENABLE_LUA52COMPAT" \
  PREFIX="$DIR/opt" \
  amalg
make \
  CROSS=clang \
  TARGET_FLAGS="-arch x86_64 -isysroot $SDKROOT" \
  TARGET_SYS=Darwin \
  BUILDMODE=static \
  XCFLAGS="-DLUAJIT_ENABLE_GC64 -DLUAJIT_ENABLE_LUA52COMPAT" \
  PREFIX="$DIR/opt" \
  install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf luajit.tar.xz -C $DIR/opt .