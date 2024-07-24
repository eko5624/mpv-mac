#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Library for ARIB STD-B24, decoding JIS 8 bit characters and parsing MPEG-TS
# depends on: libpng(zlib)
cd $PACKAGES
git clone https://github.com/nkoriyama/aribb24.git
cd aribb24
./bootstrap
./configure \
  --prefix="$DIR/opt" \
  --disable-shared \
  --enable-static
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf aribb24.tar.xz -C $DIR/opt .