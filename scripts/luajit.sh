#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Just-In-Time Compiler (JIT) for the Lua programming language
cd $PACKAGES
git clone https://github.com/LuaJIT/LuaJIT.git
cd LuaJIT
make -C src \
  HOST_CC="clang -target $(uname -m)-apple-macos11.0" \
  TARGET_CC="clang -target $ARCHS-apple-macos11.0 -isysroot $SDKROOT" \
  PREFIX="$DIR/opt" \
  amalg
make \
  HOST_CC="clang -target $(uname -m)-apple-macos11.0" \
  TARGET_CC="clang -target $ARCHS-apple-macos11.0 -isysroot $SDKROOT" \
  PREFIX="$DIR/opt" \
  install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf luajit.tar.xz -C $DIR/opt .
