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

# Bauer stereophonic-to-binaural DSP
# depends on: libsndfile(flac(libogg), lame(ncurses), libogg, libvorbis(libogg), mpg123, opus)
cd $PACKAGES
git clone https://github.com/alexmarsev/libbs2b.git
cd libbs2b
# Build library only
curl -OL https://raw.githubusercontent.com/shinchiro/mpv-winbuild-cmake/master/packages/libbs2b-0001-build-library-only.patch
patch -p1 -i libbs2b-0001-build-library-only.patch
./autogen.sh
./configure "${myconf[@]}"
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libbs2b.tar.xz -C $DIR/opt .