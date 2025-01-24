#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --prefix="$DIR/opt"
    --sysconfdir="$DIR/opt/etc"
    --localstatedir="$DIR/opt/var"
    --disable-shared
    --enable-static
    --disable-silent-rules
    --enable-devel-docs=no
    --with-doxygen=no
    PYTHON=$TOOLS/bin/python3
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

# X.Org: Interface to the X Window System"protocol
# depends on: xcb-proto, libXau(util-macros xorgproto(util-macros)), libXdmcp(xorgproto(util-macros))
# fix no package 'xcb-proto' found
PKG_CONFIG_PATH="${WORKSPACE}/share/pkgconfig:$PKG_CONFIG_PATH"
cd $PACKAGES
curl -OL "https://xcb.freedesktop.org/dist/libxcb-$VER_LIBXCB.tar.gz"
tar -xvf libxcb-$VER_LIBXCB.tar.gz 2>/dev/null >/dev/null
cd libxcb-$VER_LIBXCB
./configure "${myconf[@]}"
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libxcb.tar.xz -C $DIR/opt .
