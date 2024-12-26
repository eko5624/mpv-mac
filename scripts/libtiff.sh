#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --prefix="$DIR/opt"
    --disable-dependency-tracking
    --disable-lzma
    --disable-webp
    --disable-zstd
    --without-x
    --disable-shared
    --enable-static
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

# TIFF library and utilities
# depends on: libjpeg-turbo, xz, zlib, zstd(lz4, xz, zlib)
cd $PACKAGES
curl -OL  "https://download.osgeo.org/libtiff/tiff-$VER_LIBTIFF.tar.xz"
tar -xvf tiff-$VER_LIBTIFF.tar.xz 2>/dev/null >/dev/null
cd tiff-$VER_LIBTIFF
./configure "${myconf[@]}"
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libtiff.tar.xz -C $DIR/opt .