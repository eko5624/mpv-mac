#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# X.Org: A Sample Authorization Protocol for X
# depends on: util-macros, xorgproto(util-macros)
PKG_CONFIG_PATH="${WORKSPACE}/share/pkgconfig:$PKG_CONFIG_PATH"
cd $PACKAGES
curl -OL "https://www.x.org/archive/individual/lib/libXau-$VER_LIBXAU.tar.xz"
tar -xvf libXau-$VER_LIBXAU.tar.xz 2>/dev/null >/dev/null
cd libXau-$VER_LIBXAU
export PKG_CONFIG_PATH="${WORKSPACE}/share/pkgconfig:$PKG_CONFIG_PATH"
./configure \
  --prefix="$DIR/opt" \
  --disable-shared \
  --enable-static
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libXau.tar.xz -C $DIR/opt .