#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# High quality MPEG Audio Layer III (MP3) encoder
# depends on: ncurses
cd $PACKAGES
curl -OL "http://downloads.sourceforge.net/lame/lame-$VER_LAME.tar.gz"
tar -xvf lame-$VER_LAME.tar.gz 2>/dev/null >/dev/null
cd lame-$VER_LAME
# Fix undefined symbol error _lame_init_old
# https://sourceforge.net/p/lame/mailman/message/36081038/
sed -i "" '/lame_init_old/d' include/libmp3lame.sym
./configure \
  --prefix="$DIR/opt" \
  --disable-debug \
  --disable-shared \
  --enable-static \
  --enable-nasm
make -j $MJOBS
make install

cd $DIR
tar -zcvf lame.tar.xz -C $DIR/opt .