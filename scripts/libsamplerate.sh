#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Library for sample rate conversion of audio data
cd $PACKAGES
git clone https://github.com/libsndfile/libsamplerate.git
cd libsamplerate
./autogen.sh
./configure \
  --prefix="$DIR/opt" \
  --disable-shared \
  --enable-static
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libsamplerate.tar.xz -C $DIR/opt .