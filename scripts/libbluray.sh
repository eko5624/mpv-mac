#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --prefix="$DIR/opt"
    --buildtype=release
    --libdir="$DIR/opt/lib"
    --default-library=static
    -Dbdj_jar=disabled
    -Dfontconfig=enabled
    -Dfreetype=enabled
    -Dlibxml2=enabled
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
git clone https://code.videolan.org/videolan/libbluray.git
cd libbluray
meson setup work "${myconf[@]}"
meson compile -C work
meson install -C work

sed -i "" 's|opt|workspace|g' $DIR/opt/lib/pkgconfig/libbluray.pc
sed -i "" 's|/Users/runner/work/mpv-mac/mpv-mac/packages ||g' $DIR/opt/lib/pkgconfig/libbluray.pc
cat $DIR/opt/lib/pkgconfig/libbluray.pc

cd $DIR
tar -zcvf libbluray.tar.xz -C $DIR/opt .
