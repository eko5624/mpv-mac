#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --prefix="$DIR/opt"
    --buildtype=release
    --default-library=static
    --libdir="$DIR/opt/lib"
    -Dwrap_mode=nodownload
    -Db_lto=true
    -Db_lto_mode=thin
    -Dcoretext=enabled
    -Dfreetype=enabled
    -Dglib=disabled
    -Dgobject=disabled
    -Dcairo=disabled
    -Dchafa=disabled
    -Dicu=disabled
    -Dtests=disabled
    -Dintrospection=disabled
    -Ddocs=disabled
    -Dutilities=disabled
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

# OpenType text shaping engine
# depends on: freetype(bzip2, libpng(zlib))
cd $PACKAGES
git clone https://github.com/harfbuzz/harfbuzz.git
cd harfbuzz
meson setup build "${myconf[@]}"
meson compile -C build
meson install -C build

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf harfbuzz.tar.xz -C $DIR/opt .