#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# depends on: libdvdcss
# C library for reading DVD-video images
cd $PACKAGES
curl -OL "https://download.videolan.org/pub/videolan/libdvdread/$VER_LIBDVDREAD/libdvdread-$VER_LIBDVDREAD.tar.bz2"
tar -xvf libdvdread-$VER_LIBDVDREAD.tar.bz2 2>/dev/null >/dev/null
cd libdvdread-$VER_LIBDVDREAD
./configure \
  --prefix="$DIR/opt" \
  --disable-shared \
  --enable-static \
  --disable-dependency-tracking
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libdvdread.tar.xz -C $DIR/opt .