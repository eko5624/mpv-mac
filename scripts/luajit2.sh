#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Just-In-Time Compiler (JIT) for the Lua programming language
cd $PACKAGES
git clone https://github.com/LuaJIT/LuaJIT.git
cd LuaJIT
make -j $MJOBS amalg BUILDMODE=mixed PREFIX="$DIR/opt" XCFLAGS=-DLUAJIT_ENABLE_GC64 -DLUAJIT_UNWIND_INTERNAL
make install PREFIX="$DIR/opt" XCFLAGS=-DLUAJIT_ENABLE_GC64 -DLUAJIT_UNWIND_INTERNAL

rm $DIR/opt/lib/*.dylib
rm -rf lua
sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc
sed -i "" 's/Libs.private: -Wl,-E -lm -ldl/Libs.private: -lm -ldl/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf luajit2.tar.xz -C $DIR/opt .