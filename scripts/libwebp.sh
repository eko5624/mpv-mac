#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --prefix="$DIR/opt"
    --disable-dependency-tracking
    --disable-gl
    --disable-shared
    --enable-static
    --with-zlib-include="${WORKSPACE}"/include
    --with-zlib-lib="${WORKSPACE}"/lib
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

# Image format providing lossless and lossy compression for web images
# depends on: giflib jpeg-turbo libpng(zlib) libtiff(libjpeg-turbo, xz, zlib, zstd(lz4, xz, zlib))
cd $PACKAGES
git clone https://chromium.googlesource.com/webm/libwebp.git
cd libwebp
./autogen.sh
./configure "${myconf[@]}"
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libwebp.tar.xz -C $DIR/opt .