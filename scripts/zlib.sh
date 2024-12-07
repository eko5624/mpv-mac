#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# General-purpose lossless data-compression library
cd $PACKAGES
curl -OL "https://github.com/madler/zlib/releases/download/v$VER_ZLIB/zlib-$VER_ZLIB.tar.xz"
tar -xvf zlib-$VER_ZLIB.tar.xz 2>/dev/null >/dev/null
cd zlib-$VER_ZLIB
mkdir out && cd out
cmake .. \
  -G "Ninja" \
  -DCMAKE_INSTALL_PREFIX="$DIR/opt" \
  -DCMAKE_TOOLCHAIN_FILE="$DIR/cmake_$ARCHS.txt" \
  -DCMAKE_OSX_ARCHITECTURES=x86_64 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=11 \
  -DCMAKE_INSTALL_NAME_DIR="$DIR/opt/lib" \
  -DINSTALL_PKGCONFIG_DIR="$DIR/opt/lib/pkgconfig" \
  -DCMAKE_BUILD_TYPE=Release \
  -DSKIP_INSTALL_LIBRARIES=OFF \
  -DBUILD_SHARED_LIBS=OFF \
  -DZLIB_COMPAT=ON \
  -DZLIB_ENABLE_TESTS=OFF \
  -DZLIBNG_ENABLE_TESTS=OFF
cmake --build .
cmake --install .

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf zlib.tar.xz -C $DIR/opt .