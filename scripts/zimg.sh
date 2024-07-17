#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Scaling, colorspace conversion, and dithering library
cd $PACKAGES
git clone --recursive https://github.com/sekrit-twc/zimg.git --branch master
cd zimg
./autogen.sh
./configure \
  --prefix="$DIR/opt" \
  --disable-shared \
  --enable-static
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf zimg.tar.xz -C $DIR/opt .