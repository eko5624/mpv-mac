#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# GNOME XML library
# depends on: libiconv, zlib
cd $PACKAGES
git clone https://github.com/GNOME/libxml2.git
cd libxml2
mkdir out && cd out
cmake .. \
  -G "Ninja" \
  -DCMAKE_INSTALL_PREFIX="$DIR/opt" \
  -DCMAKE_TOOLCHAIN_FILE="$DIR/cmake_$ARCHS.txt" \
  -DCMAKE_OSX_ARCHITECTURES=$ARCHS \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOSX_TARGET \
  -DCMAKE_INSTALL_NAME_DIR="$DIR/opt/lib" \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
  -DLIBXML2_WITH_ZLIB=ON \
  -DLIBXML2_WITH_ICONV=ON \
  -DLIBXML2_WITH_LZMA=OFF \
  -DLIBXML2_WITH_PYTHON=OFF \
  -DLIBXML2_WITH_TESTS=OFF \
  -DLIBXML2_WITH_HTTP=OFF \
  -DLIBXML2_WITH_PROGRAMS=OFF
cmake --build . -j $MJOBS
cmake --install .

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libxml2.tar.xz -C $DIR/opt .
