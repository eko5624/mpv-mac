#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# TIFF library and utilities
# depends on: libjpeg-turbo, xz, zlib, zstd(lz4, xz, zlib)
cd $PACKAGES
curl -OL  "https://download.osgeo.org/libtiff/tiff-$VER_LIBTIFF.tar.xz"
tar -xvf tiff-$VER_LIBTIFF.tar.xz 2>/dev/null >/dev/null
cd tiff-$VER_LIBTIFF
./configure \
  --prefix="$DIR/opt" \
  --disable-dependency-tracking \
  --disable-lzma \
  --disable-webp \
  --disable-zstd \
  --without-x \
  --disable-shared \
  --enable-static
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libtiff.tar.xz -C $DIR/opt .