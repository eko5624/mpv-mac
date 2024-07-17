#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# depends on: libogg
# Free lossless audio codec
cd $PACKAGES
git clone https://gitlab.xiph.org/xiph/flac.git
cd flac
./autogen.sh
./configure \
  --prefix="$DIR/opt" \
  --enable-static \
  --disable-shared \
  --disable-debug \
  --disable-dependency-tracking \
  --disable-examples
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf flac.tar.xz -C $DIR/opt .