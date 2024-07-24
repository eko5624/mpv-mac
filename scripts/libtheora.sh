#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Open video compression format
# depends on: libogg libvorbis(libogg)
cd $PACKAGES
git clone https://gitlab.xiph.org/xiph/theora.git
cd theora
cp "${WORKSPACE}"/share/libtool/*/config.{guess,sub} ./
./autogen.sh
./configure \
  --prefix="$DIR/opt" \
  --with-ogg-libraries="${WORKSPACE}"/lib \
  --with-ogg-includes="${WORKSPACE}"/include/ \
  --with-vorbis-libraries="${WORKSPACE}"/lib \
  --with-vorbis-includes="${WORKSPACE}"/include/ \
  --disable-oggtest \
  --disable-vorbistest \
  --disable-examples \
  --disable-asm \
  --disable-spec \
  --disable-shared \
  --enable-static
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libtheora.tar.xz -C $DIR/opt .