#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# General-purpose lossless data-compression library
cd $PACKAGES
curl -OL "https://github.com/madler/zlib/releases/download/v$VER_ZLIB/zlib-$VER_ZLIB.tar.xz"
tar -xvf zlib-$VER_ZLIB.tar.xz 2>/dev/null >/dev/null
cd zlib-$VER_ZLIB
./configure \
  --prefix="$DIR/opt" \
  --disable-shared \
  --enable-static
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf zlib.tar.xz -C $DIR/opt .