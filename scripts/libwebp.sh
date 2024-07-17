#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

#depends on: giflib jpeg-turbo libpng(zlib) libtiff(libjpeg-turbo, xz, zlib, zstd(lz4, xz, zlib))
# Image format providing lossless and lossy compression for web images
cd $PACKAGES
git clone https://chromium.googlesource.com/webm/libwebp.git
cd libwebp
./autogen.sh
./configure \
  --prefix="$DIR/opt" \
  --disable-dependency-tracking \
  --disable-gl \
  --disable-shared \
  --enable-static \
  --with-zlib-include="${WORKSPACE}"/include/ \
  --with-zlib-lib="${WORKSPACE}"/lib
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libwebp.tar.xz -C $DIR/opt .