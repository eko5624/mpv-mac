#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --prefix="$DIR/opt"
    --enable-static
    --disable-shared
    --with-ogg-includes="$WORKSPACE/include"
    --with-ogg-libraries="$WORKSPACE/lib"
    --disable-doxygen-docs
    --disable-xmms-plugin
    --disable-thorough-tests
    --disable-oggtest
    --disable-examples
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

# Free lossless audio codec
# depends on: libogg
cd $PACKAGES
git clone https://gitlab.xiph.org/xiph/flac.git
cd flac
./autogen.sh
./configure "${myconf[@]}" \
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf flac.tar.xz -C $DIR/opt .
