#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --prefix="$DIR/opt"
    --buildtype=release
    --libdir="$DIR/opt/lib"
    --default-library=static
    -Denable_tests=false
)

if [[ ("$(uname -m)" == "x86_64") && ("$ARCHS" == "arm64") ]]; then
    myconf+=(
        --cross-file=$DIR/meson_arm64.txt
    )
fi

if [[ ("$(uname -m)" == "arm64") && ("$ARCHS" == "x86_64") ]]; then
    myconf+=(
        --cross-file=$DIR/meson_x86_64.txt
    )
fi

# AV1 decoder targeted to be small and fast
cd $PACKAGES
git clone https://github.com/videolan/dav1d.git
cd dav1d
meson setup work "${myconf[@]}"
meson compile -C work
meson install -C work

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf dav1d.tar.xz -C $DIR/opt .