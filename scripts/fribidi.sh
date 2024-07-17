#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Implementation of the Unicode BiDi algorithm
cd $PACKAGES
git clone https://github.com/fribidi/fribidi.git
cd fribidi
meson setup build \
  --prefix="$DIR/opt" \
  --default-library=static \
  -Dwrap_mode=nodownload \
  -Dbuildtype=release \
  -Db_lto=true \
  -Db_lto_mode=thin \
  -Dbin=false \
  -Ddeprecated=false \
  -Ddocs=false \
  -Dtests=false
meson compile -C build
meson install -C build

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf fribidi.tar.xz -C $DIR/opt .