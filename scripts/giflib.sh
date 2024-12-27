#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    PREFIX="$DIR/opt"
)

if [[ ("$(uname -m)" == "x86_64") && ("$ARCHS" == "arm64") ]]; then
    myconf+=(
        CC="xcrun -sdk macosx clang"
        CFLAGS="-arch arm64 -mmacosx-version-min=11.0"
        LDFLAGS="-arch arm64 -mmacosx-version-min=11.0"
    )
fi

if [[ ("$(uname -m)" == "arm64") && ("$ARCHS" == "x86_64") ]]; then
    myconf+=(
        CC="xcrun -sdk macosx clang"
        CFLAGS="-arch x86_64 -mmacosx-version-min=11.0"
        LDFLAGS="-arch x86_64 -mmacosx-version-min=11.0"
    )
fi

# Library and utilities for processing GIFs
cd $PACKAGES
curl -OL "https://netcologne.dl.sourceforge.net/project/giflib/giflib-$VER_GIFLIB.tar.gz"
tar -xvf giflib-$VER_GIFLIB.tar.gz 2>/dev/null >/dev/null
cd giflib-$VER_GIFLIB
make "${myconf[@]}" all
make "${myconf[@]}" install

cd $DIR
tar -zcvf giflib.tar.xz -C $DIR/opt .