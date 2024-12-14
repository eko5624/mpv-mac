#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Free lossless audio codec
# depends on: libogg
cd $PACKAGES
git clone https://gitlab.xiph.org/xiph/flac.git
cd flac
./autogen.sh
./configure $BUILD_HOST \
  --prefix="$DIR/opt" \
  --enable-static \
  --disable-shared \
  --with-ogg-includes="$WORKSPACE/include" \
  --with-ogg-libraries="$WORKSPACE/lib" \
  --disable-doxygen-docs \
  --disable-xmms-plugin \
  --disable-thorough-tests \
  --disable-oggtest \
  --disable-examples
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf flac.tar.xz -C $DIR/opt .
