#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --prefix="$DIR/opt"
    --disable-shared
    --enable-static
    --disable-imlib2
    --disable-cocoa
    --disable-csharp
    --disable-doc
    --disable-java
    --disable-ncurses
    --disable-python
    --disable-ruby
    --disable-slang
    --disable-x11
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

# Convert pixel information into colored ASCII art
cd $PACKAGES
git clone https://github.com/cacalabs/libcaca.git
cd libcaca
# Fix undefined reference to _caca_alloc2d
curl $CURL_RETRIES -OL https://github.com/cacalabs/libcaca/pull/70.patch
patch -p1 -i 70.patch
./bootstrap
./configure "${myconf[@]}"
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libcaca.tar.xz -C $DIR/opt .