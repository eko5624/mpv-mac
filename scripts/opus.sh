#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Audio codec
cd $PACKAGES
git clone https://github.com/xiph/opus.git
cd opus
mkdir out && cd out
cmake .. \
  -G "Ninja" \
  -DCMAKE_INSTALL_PREFIX="$DIR/opt" \
  -DCMAKE_TOOLCHAIN_FILE="$DIR/cmake_$ARCHS.txt" \
  -DCMAKE_OSX_ARCHITECTURES=$ARCHS \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOSX_TARGET \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_NAME_DIR="$DIR/opt/lib" \
  -DBUILD_SHARED_LIBS=OFF \
  -DBUILD_TESTING=OFF
cmake --build . -j $MJOBS
cmake --install .

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf opus.tar.xz -C $DIR/opt .
