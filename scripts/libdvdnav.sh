#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# DVD navigation library
# depends on: libdvdread(libdvdcss)
cd $PACKAGES
curl -OL "https://download.videolan.org/pub/videolan/libdvdnav/$VER_LIBDVDNAV/libdvdnav-$VER_LIBDVDNAV.tar.bz2"
tar -xvf libdvdnav-$VER_LIBDVDNAV.tar.bz2 2>/dev/null >/dev/null
cd libdvdnav-$VER_LIBDVDNAV
./configure \
  --prefix="$DIR/opt" \
  --disable-shared \
  --enable-static \
  --disable-dependency-tracking
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libdvdnav.tar.xz -C $DIR/opt .