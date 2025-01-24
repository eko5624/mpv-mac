#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --prefix="$DIR/opt"
    --with-ogg-libraries="${WORKSPACE}/lib"
    --with-ogg-includes="${WORKSPACE}/include"
    --with-vorbis-libraries="${WORKSPACE}/lib"
    --with-vorbis-includes="${WORKSPACE}/include"
    --disable-oggtest
    --disable-vorbistest
    --disable-examples
    --disable-asm
    --disable-spec
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

# Open video compression format
# depends on: libogg libvorbis(libogg)
cd $PACKAGES
git clone https://gitlab.xiph.org/xiph/theora.git
cd theora
cp "${TOOLS}"/share/libtool/*/config.{guess,sub} ./
./autogen.sh
./configure "${myconf[@]}"
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libtheora.tar.xz -C $DIR/opt .