#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# depends on: libpng(zlib)
# A VBI decoding library which can be used by FFmpeg to decode DVB teletext pages and DVB teletext subtitles
cd $PACKAGES
git clone https://github.com/zapping-vbi/zvbi.git --branch main
cd zvbi
./autogen.sh
./configure \
  --prefix="$DIR/opt" \
  --disable-dependency-tracking \
  --disable-silent-rules \
  --without-x \
  --disable-shared \
  --enable-static
make -C src
make -C src install
make SUBDIRS=. install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf zvbi.tar.xz -C $DIR/opt .