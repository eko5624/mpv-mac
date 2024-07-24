#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# X.Org: Protocol Headers
# depends on: util-macros
PKG_CONFIG_PATH="${WORKSPACE}/share/pkgconfig:$PKG_CONFIG_PATH"
cd $PACKAGES
curl -OL "https://xorg.freedesktop.org/archive/individual/proto/xorgproto-$VER_XORGPROTO.tar.gz"
tar -xvf xorgproto-$VER_XORGPROTO.tar.gz 2>/dev/null >/dev/null
cd xorgproto-$VER_XORGPROTO
./configure \
  --prefix="$DIR/opt" \
  --sysconfdir=$DIR/opt/etc \
  --localstatedir=$DIR/opt/var \
  --disable-dependency-tracking \
  --disable-silent-rules
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/share/pkgconfig/*.pc

cd $DIR
tar -zcvf xorgproto.tar.xz -C $DIR/opt .