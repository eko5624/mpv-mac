#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --prefix="$DIR/opt"
    --disable-debug
    --disable-shared
    --enable-static
    --enable-nasm
)

if [[ ("$(uname -m)" == "x86_64") && ("$ARCHS" == "arm64") ]]; then
    myconf+=(
        --host=aarch64-apple-darwin
        --target=arm64-apple-macos11.0
    )
fi

if [[ ("$(uname -m)" == "arm64") && ("$ARCHS" == "x86_64") ]]; then
    myconf+=(
        --host=x86_64-apple-darwin
        --target=x86_64-apple-macos11.0
    )
fi

# High quality MPEG Audio Layer III (MP3) encoder
# depends on: ncurses
cd $PACKAGES
git clone https://github.com/eko5624/lame.git
cd lame
# Fix undefined symbol error _lame_init_old
# https://sourceforge.net/p/lame/mailman/message/36081038/
sed -i "" '/lame_init_old/d' include/libmp3lame.sym
./configure "${myconf[@]}"
make -j $MJOBS
make install

cd $DIR
tar -zcvf lame.tar.xz -C $DIR/opt .