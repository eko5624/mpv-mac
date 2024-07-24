#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# XML-based font configuration API for X Windows
# depends on: expat, bzip2, freetype2(bzip2, libpng(zlib)), gettext(libxml2 ncurses)
cp $DIR/intl.pc $WORKSPACE/lib/pkgconfig
rm $WORKSPACE/lib/*.la
cd $PACKAGES
git clone https://gitlab.freedesktop.org/fontconfig/fontconfig.git
cd fontconfig
./autogen.sh
./configure \
  --prefix="$DIR/opt" \
  --disable-docs \
  --disable-shared \
  --enable-static \
  --with-libiconv="$WORKSPACE"
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc
#fix Undefined symbols when linked: "_libintl_dgettext", referenced from: _FcConfigFileInfoIterGet in libfontconfig.a(fccfg.o)
sed -i "" 's/-lfontconfig/-lfontconfig -lintl -liconv/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf fontconfig.tar.xz -C $DIR/opt .
