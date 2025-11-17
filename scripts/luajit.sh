#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    BUILDMODE=static
    PREFIX="$DIR/opt"
)

if [[ ("$(uname -m)" == "x86_64") && ("$ARCHS" == "arm64") ]]; then
    myconf+=(
        CFLAGS=""
        LDFLAGS=""
        DEFAULT_CC=clang
        CROSS="$XCTOOLCHAIN"
        TARGET_FLAGS="-arch arm64 -isysroot $SDKROOT"
        TARGET_SYS=Darwin
    )
fi

if [[ ("$(uname -m)" == "arm64") && ("$ARCHS" == "x86_64") ]]; then
    myconf+=(
        CFLAGS=""
        LDFLAGS=""
        DEFAULT_CC=clang
        CROSS="$XCTOOLCHAIN"
        TARGET_FLAGS="-arch x86_64 -isysroot $SDKROOT"
        TARGET_SYS=Darwin
    )
fi

# Just-In-Time Compiler (JIT) for the Lua programming language
cd $PACKAGES
git clone https://github.com/LuaJIT/LuaJIT.git

unset CFLAGS LDFLAGS
cd LuaJIT
make -C src "${myconf[@]}" amalg
make "${myconf[@]}" install

sed -i "" 's/Libs.private: -lm -ldl/Libs.private: -Wl,-E -lm -ldl/g' $DIR/opt/lib/pkgconfig/*.pc
sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf luajit.tar.xz -C $DIR/opt .
