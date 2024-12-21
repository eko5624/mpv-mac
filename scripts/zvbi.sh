#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# A VBI decoding library which can be used by FFmpeg to decode DVB teletext pages and DVB teletext subtitles
# depends on: libpng(zlib)
rm $DIR/workspace/lib/*.la
cd $PACKAGES
git clone https://github.com/zapping-vbi/zvbi.git --branch main
export ac_cv_func_realloc_0_nonnull=yes
cd zvbi
./autogen.sh
./configure $BUILD_HOST \
  --prefix="$DIR/opt" \
  --disable-dependency-tracking \
  --disable-silent-rules \
  --without-x \
  --disable-shared \
  --enable-static
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf zvbi.tar.xz -C $DIR/opt .