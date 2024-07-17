#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# depends on: flac(libogg), lame(ncurses), libogg, libvorbis(libogg), mpg123, opus
# C library for files containing sampled sound
cd $PACKAGES
git clone https://github.com/libsndfile/libsndfile.git
cd libsndfile
mkdir out && cd out
cmake .. \
  -G "Ninja" \
  -DCMAKE_INSTALL_PREFIX="$DIR/opt" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_NAME_DIR="$DIR/opt/lib" \
  -DCMAKE_FIND_ROOT_PATH="$WORKSPACE" \
  -DBUILD_SHARED_LIBS=OFF \
  -DBUILD_PROGRAMS=ON \
  -DENABLE_PACKAGE_CONFIG=ON \
  -DINSTALL_PKGCONFIG_MODULE=ON \
  -DBUILD_EXAMPLES=OFF \
  -DPYTHON_EXECUTABLE="${WORKSPACE}"/bin/python3
cmake --build . -j $MJOBS
cmake --install .

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libsndfile.tar.xz -C $DIR/opt .