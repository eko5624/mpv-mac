#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# depends on: xorgproto(util-macros)
# X.Org: X Display Manager Control Protocol library

PKG_CONFIG_PATH="${WORKSPACE}/share/pkgconfig:$PKG_CONFIG_PATH"
cd $PACKAGES
curl -OL "https://www.x.org/archive/individual/lib/libXdmcp-$VER_LIBXDMCP.tar.xz"
tar -xvf libXdmcp-$VER_LIBXDMCP.tar.xz 2>/dev/null >/dev/null
cd libXdmcp-$VER_LIBXDMCP
export PKG_CONFIG_PATH="${WORKSPACE}/share/pkgconfig:$PKG_CONFIG_PATH"
./configure \
  --prefix="$DIR/opt" \
  --disable-shared \
  --enable-static
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libXdmcp.tar.xz -C $DIR/opt .