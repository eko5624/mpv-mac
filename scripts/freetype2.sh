#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --prefix="$DIR/opt"
    --enable-freetype-config
    --without-harfbuzz
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

# Software library to render fonts
# depends on: bzip2, libpng(zlib)
cd $PACKAGES
git clone --recursive https://github.com/freetype/freetype.git
cd freetype
#fix glibtoolize: command not found
sed -i "" 's/glibtoolize/libtoolize/g' autogen.sh
./autogen.sh
./configure "${myconf[@]}"
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf freetype2.tar.xz -C $DIR/opt .
