#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --prefix="$DIR/opt"
    --enable-static
    --disable-shared
    --disable-silent-rules
    --with-libiconv-prefix="${WORKSPACE}"
    --with-included-gettext
    --with-included-glib
    --with-included-libcroco
    --with-included-libunistring
    --with-included-libxml
    --disable-java
    --disable-csharp
    --without-git
    --without-cvs
    --without-xz
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

# gettext: GNU internationalization (i18n) and localization (l10n) library
# depends on: libxml2(zlib), ncurses
cd $PACKAGES
curl -OL "https://ftpmirror.gnu.org/gettext/gettext-$VER_GETTEXT.tar.gz"
tar -xvf gettext-$VER_GETTEXT.tar.gz 2>/dev/null >/dev/null
cd gettext-$VER_GETTEXT
./configure "${myconf[@]}"
make -j $MJOBS
make install

mkdir -p $DIR/opt/lib/pkgconfig
cp $DIR/intl.pc $DIR/opt/lib/pkgconfig
sed -i "" 's|@prefix@|'"${WORKSPACE}"'|g' $DIR/opt/lib/pkgconfig/intl.pc
sed -i "" 's|@VERSION@|'"${VER_GETTEXT}"'|g' $DIR/opt/lib/pkgconfig/intl.pc

cd $DIR
tar -zcvf gettext.tar.xz -C $DIR/opt .
