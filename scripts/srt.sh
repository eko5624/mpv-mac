#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# depends on: openssl
# Secure Reliable Transport
cd $PACKAGES
git clone https://github.com/Haivision/srt.git
cd srt
export OPENSSL_ROOT_DIR="${WORKSPACE}"
export OPENSSL_LIB_DIR="${WORKSPACE}"/lib
export OPENSSL_INCLUDE_DIR="${WORKSPACE}"/include/
mkdir out && cd out
cmake .. \
  -G "Ninja" \
  -DCMAKE_INSTALL_PREFIX="$DIR/opt" \
  -DCMAKE_INSTALL_NAME_DIR="$DIR/opt/lib" \
  -DCMAKE_FIND_ROOT_PATH="$WORKSPACE" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_INSTALL_BINDIR=bin \
  -DCMAKE_INSTALL_INCLUDEDIR=include \
  -DBUILD_SHARED_LIBS=OFF \
  -DENABLE_SHARED=OFF \
  -DENABLE_APPS=OFF \
  -DENABLE_STATIC=ON \
  -DUSE_STATIC_LIBSTDCXX=ON
cmake --build . -j $MJOBS
cmake --install .

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf srt.tar.xz -C $DIR/opt .