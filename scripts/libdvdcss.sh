#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --prefix="$DIR/opt"
    --buildtype=release
    --libdir="$DIR/opt/lib"
    --default-library=static
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

# Access DVDs as block devices without the decryption
cd $PACKAGES
git clone https://code.videolan.org/videolan/libdvdcss.git
cd libdvdcss
meson setup work "${myconf[@]}"
meson compile -C work
meson install -C work

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libdvdcss.tar.xz -C $DIR/opt .