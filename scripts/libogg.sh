#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Ogg Bitstream Library
cd $PACKAGES
git clone https://github.com/xiph/ogg.git
cd ogg
./autogen.sh
./configure \
  --prefix="$DIR/opt" \
  --disable-shared \
  --enable-static
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libogg.tar.xz -C $DIR/opt .