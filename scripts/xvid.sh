#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# High-performance, high-quality MPEG-4 video library
cd $PACKAGES
curl -OL "https://downloads.xvid.com/downloads/xvidcore-$VER_XVID.tar.gz"
tar -xvf xvidcore-$VER_XVID.tar.gz 2>/dev/null >/dev/null
cd xvidcore/build/generic
./configure \
  --prefix="$DIR/opt" \
  --disable-shared \
  --enable-static
make -j $MJOBS
make install

cd $DIR
tar -zcvf xvid.tar.xz -C $DIR/opt .