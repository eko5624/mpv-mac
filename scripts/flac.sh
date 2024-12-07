#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Free lossless audio codec
# depends on: libogg
cd $PACKAGES
git clone https://gitlab.xiph.org/xiph/flac.git
cd flac
mkdir out && cd out
cmake .. \
  -G "Ninja" \
  -DCMAKE_INSTALL_PREFIX="$DIR/opt" \
  -DCMAKE_TOOLCHAIN_FILE="$DIR/cmake_$ARCHS.txt" \
  -DCMAKE_OSX_ARCHITECTURES=x86_64 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=11 \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_NAME_DIR="$DIR/opt/lib" \
  -DBUILD_SHARED_LIBS=OFF \
  -DBUILD_DOCS=OFF \
  -DBUILD_EXAMPLES=OFF \
  -DBUILD_TESTING=OFF \
  -DINSTALL_MANPAGES=OFF
cmake --build . -j $MJOBS
cmake --install .

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf flac.tar.xz -C $DIR/opt .
