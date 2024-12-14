#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# C library for files containing sampled sound
# depends on: flac(libogg), lame(ncurses), libogg, libvorbis(libogg), mpg123, opus
cd $PACKAGES
git clone https://github.com/libsndfile/libsndfile.git
cd libsndfile
mkdir out && cd out
cmake .. \
  -G "Ninja" \
  -DCMAKE_INSTALL_PREFIX="$DIR/opt" \
  -DCMAKE_TOOLCHAIN_FILE="$DIR/cmake_$ARCHS.txt" \
  -DCMAKE_OSX_ARCHITECTURES=$ARCHS \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOS \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_NAME_DIR="$DIR/opt/lib" \
  -DBUILD_SHARED_LIBS=OFF \
  -DBUILD_EXAMPLES=OFF \
  -DPYTHON_EXECUTABLE=$TOOLS/bin/python3
cmake --build . -j $MJOBS
cmake --install .

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libsndfile.tar.xz -C $DIR/opt .
