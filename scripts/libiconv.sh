#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

cd $PACKAGES
curl -OL "https://ftp.gnu.org/gnu/libiconv/libiconv-$VER_LIBICONV.tar.gz"
tar -xvf libiconv-$VER_LIBICONV.tar.gz 2>/dev/null >/dev/null
cd libiconv-$VER_LIBICONV
#curl -OL "https://raw.githubusercontent.com/Homebrew/patches/9be2793af/libiconv/patch-utf8mac.diff"
#patch -p1 -i patch-utf8mac.diff
./configure \
  --prefix="$DIR/opt" \
  --disable-debug \
  --disable-dependency-tracking \
  --enable-extra-encodings \
  --disable-shared \
  --enable-static \
  --with-pic
make -j $MJOBS
make install

mkdir -p $DIR/opt/lib/pkgconfig
sed -i "" 's|/Users/runner/work/mpv-mac/mpv-mac/workspace|\${DIR}/opt|g' $DIR/iconv.pc
sed -i "" 's|@VERSION@|'"${VER_LIBICONV}"'|g' $DIR/iconv.pc
cp $DIR/iconv.pc $DIR/opt/lib/pkgconfig
cat $DIR/opt/lib/pkgconfig/iconv.pc

cd $DIR
tar -zcvf libiconv.tar.xz -C $DIR/opt .
