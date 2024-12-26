#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --prefix="$DIR/opt"
    --default-library=static
    -Dwrap_mode=nodownload
    -Dbuildtype=release
    -Dcoretext=enabled
    -Dasm=enabled
    -Dlibunibreak=enabled
    -Dfontconfig=disabled
    -Ddirectwrite=disabled
)

if [[ ("$(uname -m)" == "x86_64") && ("$ARCHS" == "arm64") ]]; then
    myconf+=(
        --cross-file=$DIR/meson_arm64.txt
    )
fi

if [[ ("$(uname -m)" == "arm64") && ("$ARCHS" == "x86_64") ]]; then
    myconf+=(
        --cross-file=$DIR/meson_x86_64.txt
    )
fi

# Subtitle renderer for the ASS/SSA subtitle format
# depends on: freetype2(libpng(zlib)), fribidi, harfbuzz, libunibreak
rm $WORKSPACE/lib/*.la
cd $PACKAGES
git clone https://github.com/libass/libass.git
cd libass
meson setup build "${myconf[@]}"
meson compile -C build
meson install -C build

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc
cat $DIR/opt/lib/pkgconfig/libass.pc
cd $DIR
tar -zcvf libass.tar.xz -C $DIR/opt .
