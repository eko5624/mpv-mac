#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Bauer stereophonic-to-binaural DSP
# depends on: libsndfile(flac(libogg), lame(ncurses), libogg, libvorbis(libogg), mpg123, opus)
cd $PACKAGES
git clone https://github.com/alexmarsev/libbs2b.git
cd libbs2b
# Build library only
curl -OL https://raw.githubusercontent.com/shinchiro/mpv-winbuild-cmake/master/packages/libbs2b-0001-build-library-only.patch
patch -p1 -i libbs2b-0001-build-library-only.patch
./autogen.sh
./configure \
  --prefix="$DIR/opt" \
  --disable-shared \
  --enable-static
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libbs2b.tar.xz -C $DIR/opt .