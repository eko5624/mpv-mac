#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# XML 1.0 parser
cd $PACKAGES
git clone https://github.com/libexpat/libexpat.git
cd libexpat/expat
autoreconf -fiv
./configure \
  --prefix="$DIR/opt" \
  --disable-shared
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf expat.tar.xz -C $DIR/opt .