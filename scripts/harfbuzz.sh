#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# OpenType text shaping engine
# depends on: freetype(bzip2, libpng(zlib))
cd $PACKAGES
git clone https://github.com/harfbuzz/harfbuzz.git
cd harfbuzz
meson setup build \
  --prefix="$DIR/opt" \
  --buildtype=release \
  --default-library=static \
  --libdir="$DIR/opt/lib" \
  -Dwrap_mode=nodownload \
  -Db_lto=true \
  -Db_lto_mode=thin \
  -Dcoretext=enabled \
  -Dfreetype=enabled \
  -Dglib=disabled \
  -Dgobject=disabled \
  -Dcairo=disabled \
  -Dchafa=disabled \
  -Dicu=disabled \
  -Dtests=disabled \
  -Dintrospection=disabled \
  -Ddocs=disabled \
  -Dutilities=disabled
meson compile -C build
meson install -C build

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf harfbuzz.tar.xz -C $DIR/opt .