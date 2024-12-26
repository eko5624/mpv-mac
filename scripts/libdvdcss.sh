#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --prefix="$DIR/opt"
    --disable-shared
    --enable-static
    --disable-dependency-tracking
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

# Access DVDs as block devices without the decryption
cd $PACKAGES
curl -OL "https://download.videolan.org/pub/videolan/libdvdcss/$VER_LIBDVDCSS/libdvdcss-$VER_LIBDVDCSS.tar.bz2"
tar -xvf libdvdcss-$VER_LIBDVDCSS.tar.bz2 2>/dev/null >/dev/null
cd libdvdcss-$VER_LIBDVDCSS
./configure "${myconf[@]}"
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libdvdcss.tar.xz -C $DIR/opt .