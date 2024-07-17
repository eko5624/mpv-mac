#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# An open-source decoder of AVS2-P2/IEEE1857.4 video coding standard
cd $PACKAGES
git clone https://github.com/pkuvcl/davs2.git
cd davs2/build/linux
./configure \
  --prefix="$DIR/opt" \
  --disable-shared \
  --enable-static \
  --disable-cli \
  --enable-lto \
  --enable-pic
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf davs2.tar.xz -C $DIR/opt .