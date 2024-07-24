#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Audio codec designed for speech
# depends on: libogg
cd $PACKAGES
git clone https://github.com/xiph/speex.git --branch master
cd speex
./autogen.sh
./configure \
  --prefix="$DIR/opt" \
  --disable-shared \
  --enable-static
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf speex.tar.xz -C $DIR/opt .