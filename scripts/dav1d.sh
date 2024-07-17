#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# AV1 decoder targeted to be small and fast
cd $PACKAGES
git clone https://github.com/videolan/dav1d.git
cd dav1d
if $MACOS_M1; then
  export CFLAGS="-arch arm64"
fi
meson setup work \
  --prefix="$DIR/opt" \
  --buildtype=release \
  --libdir="$DIR/opt/lib" \
  --default-library=static \
  -Denable_tests=false
meson compile -C work
meson install -C work

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf dav1d.tar.xz -C $DIR/opt .