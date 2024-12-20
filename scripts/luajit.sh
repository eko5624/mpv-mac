#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Just-In-Time Compiler (JIT) for the Lua programming language
cd $PACKAGES
git clone https://github.com/LuaJIT/LuaJIT.git
cd LuaJIT
make -C src \
  TARGET_CFLAGS=$CFLAGS \
  TARGET_LDFLAGS=$LDFLAGS \
  PREFIX="$DIR/opt" \
  amalg
make \
  TARGET_CFLAGS=$CFLAGS \
  TARGET_LDFLAGS=$LDFLAGS \
  PREFIX="$DIR/opt" \
  install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf luajit.tar.xz -C $DIR/opt .
