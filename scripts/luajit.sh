#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Just-In-Time Compiler (JIT) for the Lua programming language
cd $PACKAGES
git clone https://github.com/LuaJIT/LuaJIT.git
cd LuaJIT
make -j $MJOBS amalg PREFIX="$DIR/opt" XCFLAGS=-DLUAJIT_ENABLE_GC64
make install PREFIX="$DIR/opt" XCFLAGS=-DLUAJIT_ENABLE_GC64

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc
sed -i "" 's/Libs.private: -Wl,-E -lm -ldl/Libs.private: -lm -ldl/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf luajit.tar.xz -C $DIR/opt .