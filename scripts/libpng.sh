#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

#depends on: zlib
# Library for manipulating PNG images
cd $PACKAGES
git clone https://github.com/glennrp/libpng.git
cd libpng
./configure \
  --prefix="$DIR/opt" \
  --disable-shared \
  --enable-static
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/libpng16.pc

cd $DIR
tar -zcvf libpng.tar.xz -C $DIR/opt .