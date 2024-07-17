#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# depends on: util-macros, xtrans(util-macros xorgproto(util-macros)), libxcb(xcb-proto libXau(util-macros xorgproto(util-macros)), libXdmcp(xorgproto(util-macros))), xorgproto(util-macros)
# X.Org: Core X11 protocol client library


rm $WORKSPACE/lib/*.la
PKG_CONFIG_PATH="${WORKSPACE}/share/pkgconfig:$PKG_CONFIG_PATH"
cd $PACKAGES
curl -OL "https://www.x.org/archive/individual/lib/libX11-$VER_LIBX11.tar.gz"
tar -xvf libX11-$VER_LIBX11.tar.gz 2>/dev/null >/dev/null
cd libX11-$VER_LIBX11
export LC_ALL=""
export LC_CTYPE="C"
./configure \
  --prefix="$DIR/opt" \
  --disable-shared \
  --enable-static
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libX11.tar.xz -C $DIR/opt .