#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Access DVDs as block devices without the decryption
cd $PACKAGES
curl -OL "https://download.videolan.org/pub/videolan/libdvdcss/$VER_LIBDVDCSS/libdvdcss-$VER_LIBDVDCSS.tar.bz2"
tar -xvf libdvdcss-$VER_LIBDVDCSS.tar.bz2 2>/dev/null >/dev/null
cd libdvdcss-$VER_LIBDVDCSS
./configure \
  --prefix="$DIR/opt" \
  --disable-shared \
  --enable-static \
  --disable-dependency-tracking
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libdvdcss.tar.xz -C $DIR/opt .