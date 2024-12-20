#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Just-In-Time Compiler (JIT) for the Lua programming language
cd $PACKAGES
git clone https://github.com/LuaJIT/LuaJIT.git
cd LuaJIT
make \
  MACOSX_DEPLOYMENT_TARGET=11.0 \
  TARGET_CFLAGS="--target=arm64-apple-macosx11.0" \
  TARGET_LDFLAGS="--target=arm64-apple-macosx11.0" \
  HOST_CFLAGS="--target=x86_64-apple-macosx11.0" \
  HOST_LDFLAGS="--target=x86_64-apple-macosx11.0" \
  PREFIX="$DIR/opt" \
  amalg
make \
  MACOSX_DEPLOYMENT_TARGET=11.0 \
  TARGET_CFLAGS="--target=arm64-apple-macosx11.0" \
  TARGET_LDFLAGS="--target=arm64-apple-macosx11.0" \
  HOST_CFLAGS="--target=x86_64-apple-macosx11.0" \
  HOST_LDFLAGS="--target=x86_64-apple-macosx11.0" \
  PREFIX="$DIR/opt" \
  install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf luajit.tar.xz -C $DIR/opt .