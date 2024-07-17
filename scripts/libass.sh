#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# depends on: freetype2(libpng(zlib)), fribidi, harfbuzz, libunibreak
# Subtitle renderer for the ASS/SSA subtitle format

rm $WORKSPACE/lib/*.la
cd $PACKAGES
git clone https://github.com/libass/libass.git
cd libass
./autogen.sh
./configure \
  --prefix="$DIR/opt" \
  --disable-fontconfig \
  --disable-shared \
  --enable-static
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc
cat $DIR/opt/lib/pkgconfig/libass.pc
cd $DIR
tar -zcvf libass.tar.xz -C $DIR/opt .
