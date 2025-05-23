#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --prefix="$DIR/opt"
    --disable-debug
    --disable-nls
    --disable-shared
    --enable-static
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

# General-purpose data compression with high compression ratio
cd $PACKAGES
curl -OL "https://github.com/tukaani-project/xz/releases/download/v$VER_XZ/xz-$VER_XZ.tar.gz"
tar -xvf xz-$VER_XZ.tar.gz 2>/dev/null >/dev/null
cd xz-$VER_XZ
./configure "${myconf[@]}"
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf xz.tar.xz -C $DIR/opt .