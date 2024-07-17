#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# H.264/AVC encoder
cd $PACKAGES
git clone https://code.videolan.org/videolan/x264.git --branch master
cd x264
./configure \
  --prefix="$DIR/opt" \
  --enable-static \
  --enable-lto \
  --disable-cli \
  --disable-opencl
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf x264.tar.xz -C $DIR/opt .