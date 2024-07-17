#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Implementation of the Unicode line and word-breaking algorithms
cd $PACKAGES
git clone https://github.com/adah1972/libunibreak.git
cd libunibreak
./autogen.sh
./configure \
  --prefix="$DIR/opt" \
  --disable-shared \
  --enable-static
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libunibreak.tar.xz -C $DIR/opt .