#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --prefix="$DIR/opt"
    --disable-dependency-tracking
    --disable-silent-rules
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

# Secure hashing function
cd $PACKAGES
git clone https://github.com/BLAKE2/libb2.git
cd libb2
./autogen.sh
# Fix -flat_namespace being used on Big Sur and later.
#curl -OL "https://raw.githubusercontent.com/Homebrew/formula-patches/03cf8088210822aa2c1ab544ed58ea04c897d9c4/libtool/configure-big_sur.diff"
#patch -p1 -i configure-big_sur.diff
./configure "${myconf[@]}"
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libb2.tar.xz -C $DIR/opt .