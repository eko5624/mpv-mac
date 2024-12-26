#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# X.Org: Core X11 protocol client library
# depends on: util-macros, xtrans(util-macros xorgproto(util-macros)), libxcb(xcb-proto libXau(util-macros xorgproto(util-macros)), libXdmcp(xorgproto(util-macros))), xorgproto(util-macros)
rm $WORKSPACE/lib/*.la
PKG_CONFIG_PATH="${WORKSPACE}/share/pkgconfig:$PKG_CONFIG_PATH"
cd $PACKAGES
curl -OL "https://www.x.org/archive/individual/lib/libX11-$VER_LIBX11.tar.gz"
tar -xvf libX11-$VER_LIBX11.tar.gz 2>/dev/null >/dev/null

myconf=(
    --prefix="$DIR/opt"
    --disable-shared
    --enable-static
)

if [[ ("$(uname -m)" == "x86_64") && ("$ARCHS" == "arm64") ]]; then
    myconf+=(
        --host=aarch64-apple-darwin
        --target=arm64-apple-macos11.0
        --disable-malloc0returnsnull
    )
fi

if [[ ("$(uname -m)" == "arm64") && ("$ARCHS" == "x86_64") ]]; then
    myconf+=(
        --host=x86_64-apple-darwin
        --target=x86_64-apple-macos11.0
        --disable-malloc0returnsnull
    )
fi  

# Fix cannot run test program while cross compiling '--disable-malloc0returnsnull'
cd libX11-$VER_LIBX11
export LC_ALL=""
export LC_CTYPE="C"
./configure "${myconf[@]}"
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libX11.tar.xz -C $DIR/opt .