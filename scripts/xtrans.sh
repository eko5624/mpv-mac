#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# depends on: util-macros xorgproto(util-macros)
# X.Org: X Network Transport layer shared code

PKG_CONFIG_PATH="${WORKSPACE}/share/pkgconfig:$PKG_CONFIG_PATH"
cd $PACKAGES
curl -OL "https://www.x.org/archive/individual/lib/xtrans-$VER_XTRANS.tar.gz"
tar -xvf xtrans-$VER_XTRANS.tar.gz 2>/dev/null >/dev/null
cd xtrans-$VER_XTRANS
#sed -i "" 's/# include <sys\/stropts.h>/# include <sys\/ioctl.h>/g' Xtranslcl.c
./configure \
--prefix="$DIR/opt" \
--enable-docs=no
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/share/pkgconfig/*.pc

cd $DIR
tar -zcvf xtrans.tar.xz -C $DIR/opt .