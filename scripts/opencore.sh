#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Audio codecs extracted from Android open source project
cd $PACKAGES
curl -OL "https://downloads.sourceforge.net/project/opencore-amr/opencore-amr/opencore-amr-$VER_OPENCORE_AMR.tar.gz"
tar -xvf opencore-amr-$VER_OPENCORE_AMR.tar.gz 2>/dev/null >/dev/null
cd opencore-amr-$VER_OPENCORE_AMR
./configure \
  --prefix="$DIR/opt" \
  --disable-shared \
  --enable-static
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf opencore.tar.xz -C $DIR/opt .