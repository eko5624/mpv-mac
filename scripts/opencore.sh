#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --prefix="$DIR/opt"
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

# Audio codecs extracted from Android open source project
cd $PACKAGES
curl -OL "https://downloads.sourceforge.net/project/opencore-amr/opencore-amr/opencore-amr-$VER_OPENCORE_AMR.tar.gz"
tar -xvf opencore-amr-$VER_OPENCORE_AMR.tar.gz 2>/dev/null >/dev/null
cd opencore-amr-$VER_OPENCORE_AMR
./configure "${myconf[@]}"
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf opencore.tar.xz -C $DIR/opt .