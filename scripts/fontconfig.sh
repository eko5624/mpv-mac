#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --prefix="$DIR/opt"
    --libdir="$DIR/opt/lib"
    --buildtype=release
    --default-library=static
    -Ddoc=disabled
    -Dtests=disabled
    -Dtools=disabled
    -Dcache-build=disabled
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

# XML-based font configuration API for X Windows
# depends on: expat, bzip2, freetype2(bzip2, libpng(zlib)), gettext(libxml2 ncurses)
rm $WORKSPACE/lib/*.la
cd $PACKAGES
git clone https://gitlab.freedesktop.org/fontconfig/fontconfig.git
cd fontconfig
meson setup build "${myconf[@]}"
meson compile -C build
meson install -C build

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc
#fix Undefined symbols when linked: "_libintl_dgettext", referenced from: _FcConfigFileInfoIterGet in libfontconfig.a(fccfg.o)
sed -i "" 's/-lfontconfig/-lfontconfig -lintl -liconv/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf fontconfig.tar.xz -C $DIR/opt .
