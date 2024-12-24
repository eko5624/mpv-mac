#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Software library to render fonts
# depends on: bzip2, libpng(zlib)
cd $PACKAGES
git clone --recursive https://github.com/freetype/freetype.git
cd freetype
meson setup build $MESON_CROSS \
  --prefix="$DIR/opt" \
  --buildtype=release \
  --default-library=static \
  --libdir="$DIR/opt/lib" \
  -Dwrap_mode=nodownload \
  -Dharfbuzz=disabled \
  -Dbrotli=disabled \
  -Dzlib=system
meson compile -C build
meson install -C build

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf freetype2.tar.xz -C $DIR/opt .
