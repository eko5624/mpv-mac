#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --prefix="$DIR/opt" \
    --disable-dependency-tracking \
    --disable-silent-rules \
    --disable-bdjava-jar \
    --disable-examples \
    --without-fontconfig \
    --without-libxml2 \
    --disable-shared \
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

# Blu-Ray disc playback library for media players like VLC
# depends on: fontconfig(expat, bzip2, freetype2, gettext(libxml2 ncurses)), freetype2(libpng(zlib)), libxml2(ncurses)
rm $WORKSPACE/lib/*.la
cd $PACKAGES
curl -OL  "https://download.videolan.org/videolan/libbluray/$VER_LIBBLURAY/libbluray-$VER_LIBBLURAY.tar.bz2"
tar -xvf libbluray-$VER_LIBBLURAY.tar.bz2 2>/dev/null >/dev/null
cd libbluray-$VER_LIBBLURAY
./configure "${myconf[@]}"
make -j $MJOBS
make install

sed -i "" 's|opt|workspace|g' $DIR/opt/lib/pkgconfig/libbluray.pc
sed -i "" 's|/Users/runner/work/mpv-mac/mpv-mac/packages ||g' $DIR/opt/lib/pkgconfig/libbluray.pc
cat $DIR/opt/lib/pkgconfig/libbluray.pc

cd $DIR
tar -zcvf libbluray.tar.xz -C $DIR/opt .
