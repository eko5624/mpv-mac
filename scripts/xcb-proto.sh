#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --prefix="$DIR/opt"
    --sysconfdir="$DIR/opt/etc"
    --localstatedir="$DIR/opt/var"
    --disable-silent-rules
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

# X.Org: XML-XCB protocol descriptions for libxcb code generation
cd $PACKAGES
curl -OL "https://xorg.freedesktop.org/archive/individual/proto/xcb-proto-${VER_XCB_PROTO}.tar.xz"
tar -xvf xcb-proto-${VER_XCB_PROTO}.tar.xz 2>/dev/null >/dev/null
cd xcb-proto-${VER_XCB_PROTO}
./configure "${myconf[@]}"
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/share/pkgconfig/*.pc

cd $DIR
tar -zcvf xcb-proto.tar.xz -C $DIR/opt .