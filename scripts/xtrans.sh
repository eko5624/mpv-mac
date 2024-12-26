#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
		--prefix="$DIR/opt"
		--enable-docs=no
)

if [[ ("$(uname -m)" == "x86_64") && ("$ARCHS" == "arm64") ]]; then
    myconf+=(
        --host=aarch64-apple-darwin
        --target=arm64-apple-macos11.0
    )
fi

if [[ ("$(uname -m)" == "arm64") && ("$ARCHS" == "x86_64") ]]; then
    myconf+=(
        --host=x86_64-apple-darwin
        --target=x86_64-apple-macos11.0
    )
fi

# X.Org: X Network Transport layer shared code
# depends on: util-macros xorgproto(util-macros)
PKG_CONFIG_PATH="${WORKSPACE}/share/pkgconfig:$PKG_CONFIG_PATH"
cd $PACKAGES
curl -OL "https://www.x.org/archive/individual/lib/xtrans-$VER_XTRANS.tar.gz"
tar -xvf xtrans-$VER_XTRANS.tar.gz 2>/dev/null >/dev/null
cd xtrans-$VER_XTRANS
#sed -i "" 's/# include <sys\/stropts.h>/# include <sys\/ioctl.h>/g' Xtranslcl.c
./configure "${myconf[@]}"
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/share/pkgconfig/*.pc

cd $DIR
tar -zcvf xtrans.tar.xz -C $DIR/opt .