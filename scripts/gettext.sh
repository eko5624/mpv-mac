#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# gettext: GNU internationalization (i18n) and localization (l10n) library
# depends on: libxml2(zlib), ncurses
cd $PACKAGES
curl -OL "https://ftpmirror.gnu.org/gettext/gettext-$VER_GETTEXT.tar.gz"
tar -xvf gettext-$VER_GETTEXT.tar.gz 2>/dev/null >/dev/null
cd gettext-$VER_GETTEXT
./configure $BUILD_HOST \
  --prefix="$DIR/opt"\
  --enable-static \
  --disable-shared \
  --disable-silent-rules \
  --with-libiconv-prefix="${WORKSPACE}" \
  --with-included-gettext \
  --with-included-glib \
  --with-included-libcroco \
  --with-included-libunistring \
  --with-included-libxml \
  --disable-java \
  --disable-csharp \
  --without-git \
  --without-cvs \
  --without-xz
make -j $MJOBS
make install

mkdir -p $DIR/opt/lib/pkgconfig
cp $DIR/intl.pc $DIR/opt/lib/pkgconfig
sed -i "" 's|@prefix@|'"${WORKSPACE}"'|g' $DIR/opt/lib/pkgconfig/intl.pc
sed -i "" 's|@VERSION@|'"${VER_GETTEXT}"'|g' $DIR/opt/lib/pkgconfig/intl.pc

cd $DIR
tar -zcvf gettext.tar.xz -C $DIR/opt .
