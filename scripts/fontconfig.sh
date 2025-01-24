#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --prefix="$DIR/opt"
    --disable-docs
    --disable-shared
    --enable-iconv
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

# XML-based font configuration API for X Windows
# depends on: expat, bzip2, freetype2(bzip2, libpng(zlib)), gettext(libxml2 ncurses)
rm $WORKSPACE/lib/*.la
cd $PACKAGES
git clone https://gitlab.freedesktop.org/fontconfig/fontconfig.git
cd fontconfig
NOCONFIGURE=1 ./autogen.sh
./configure "${myconf[@]}"
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc
#fix Undefined symbols when linked: "_libintl_dgettext", referenced from: _FcConfigFileInfoIterGet in libfontconfig.a(fccfg.o)
sed -i "" 's/-lfontconfig/-lfontconfig -lintl -liconv/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf fontconfig.tar.xz -C $DIR/opt .
