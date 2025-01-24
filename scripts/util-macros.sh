#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
		--prefix="$DIR/opt"
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

# X.Org: Set of autoconf macros used to build other xorg packages
cd $PACKAGES
curl -OL "https://www.x.org/archive/individual/util/util-macros-${VER_UTIL_MACROS}.tar.xz"
tar -xvf util-macros-${VER_UTIL_MACROS}.tar.xz 2>/dev/null >/dev/null
cd util-macros-${VER_UTIL_MACROS}
./configure "${myconf[@]}"
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/share/pkgconfig/*.pc

cd $DIR
tar -zcvf util-macros.tar.xz -C $DIR/opt .
