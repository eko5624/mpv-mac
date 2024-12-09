#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Subtitle renderer for the ASS/SSA subtitle format
# depends on: freetype2(libpng(zlib)), fribidi, harfbuzz, libunibreak
rm $WORKSPACE/lib/*.la
cd $PACKAGES
git clone https://github.com/libass/libass.git
cd libass
meson setup build \
  --prefix="$DIR/opt" \
  --default-library=static \
  --cross-file="$DIR/meson_$ARCHS.txt" \
  -Dwrap_mode=nodownload \
  -Dbuildtype=release \
  -Dcoretext=enabled \
  -Dasm=enabled \
  -Dlibunibreak=enabled \
  -Dfontconfig=disabled \
  -Ddirectwrite=disabled
meson compile -C build
meson install -C build

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc
cat $DIR/opt/lib/pkgconfig/libass.pc
cd $DIR
tar -zcvf libass.tar.xz -C $DIR/opt .
