#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

#depends on: cjson, mbedtls
# Reliable Internet Stream Transport (RIST)
cd $PACKAGES
git clone https://code.videolan.org/rist/librist.git
cd librist
#fix error: no member named 'st_mtim' in 'struct stat'
patch -p1 -i ../../librist-fix-st_mtim.patch
meson setup build \
  --prefix="$DIR/opt" \
  --buildtype=release \
  --default-library=static \
  --libdir="$DIR/opt/lib" \
  -Duse_mbedtls=true \
  -Dbuiltin_mbedtls=false \
  -Dbuilt_tools=false \
  -Dtest=false
meson compile -C build
meson install -C build

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf librist.tar.xz -C $DIR/opt .
