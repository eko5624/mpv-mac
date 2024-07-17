#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# depends on: libjpeg-turbo, libtiff(libjpeg-turbo, zlib, zstd(lz4, xz, zlib), xz)
# Color management engine supporting ICC profiles
cd $PACKAGES
git clone https://github.com/mm2/Little-CMS.git
cd Little-CMS
./configure \
  --prefix="$DIR/opt" \
  --disable-shared \
  --enable-static
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf lcms2.tar.xz -C $DIR/opt .