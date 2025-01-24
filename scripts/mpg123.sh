#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

if [ "$ARCHS" == "x86_64" ]; then
  CPU_ARCH="x86-64"
elif [ "$ARCHS" == "arm64" ]; then
  CPU_ARCH="aarch64"
fi

myconf=(
    --prefix="$DIR/opt"
    --disable-debug
    --disable-dependency-tracking
    --enable-static
    --with-default-audio=coreaudio
    --disable-shared
    --enable-static
)

if [[ ("$(uname -m)" == "x86_64") && ("$ARCHS" == "arm64") ]]; then
    myconf+=(
        --host=aarch64-apple-darwin
        --target=arm64-apple-macos11.0
        --with-cpu=aarch64
    )
fi

if [[ ("$(uname -m)" == "arm64") && ("$ARCHS" == "x86_64") ]]; then
    myconf+=(
        --host=x86_64-apple-darwin
        --target=x86_64-apple-macos11.0
        --with-cpu=x86-64
    )
fi

# MP3 player for Linux and UNIX
cd $PACKAGES
curl -OL "https://downloads.sourceforge.net/project/mpg123/mpg123/$VER_MPG123/mpg123-$VER_MPG123.tar.bz2"
tar -xvf mpg123-$VER_MPG123.tar.bz2 2>/dev/null >/dev/null
cd mpg123-$VER_MPG123
./configure "${myconf[@]}"
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf mpg123.tar.xz -C $DIR/opt .
