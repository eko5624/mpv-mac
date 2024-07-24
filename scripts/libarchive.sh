#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Multi-format archive and compression library
# depends on: bzip2, expat, libb2, lz4, xz, zlib, zstd(lz4, xz, zlib)
cd $PACKAGES
git clone https://github.com/libarchive/libarchive.git
cd libarchive
mkdir out && cd out
cmake .. \
  -G "Ninja" \
  -DCMAKE_INSTALL_PREFIX="$DIR/opt" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_NAME_DIR="$DIR/opt/lib" \
  -DCMAKE_FIND_ROOT_PATH="$WORKSPACE" \
  -DBUILD_SHARED_LIBS=OFF \
  -DENABLE_ZLIB=ON \
  -DENABLE_ZSTD=ON \
  -DENABLE_BZip2=ON \
  -DENABLE_EXPAT=ON \
  -DENABLE_LIBB2=ON \
  -DENABLE_LZ4=ON \
  -DENABLE_LZMA=ON \
  -DENABLE_ICONV=OFF \
  -DENABLE_LZO=OFF \
  -DENABLE_CPIO=OFF \
  -DENABLE_CNG=OFF \
  -DENABLE_CAT=OFF \
  -DENABLE_TAR=OFF \
  -DENABLE_WERROR=OFF \
  -DBUILD_TESTING=OFF \
  -DENABLE_TEST=OFF
cmake --build . -j $MJOBS
cmake --install .

sed -i '' "s|Libs.private: |Libs.private: -liconv |g" $DIR/opt/lib/pkgconfig/libarchive.pc
sed -i '' "/Requires.private: iconv/d" $DIR/opt/lib/pkgconfig/libarchive.pc
sed -i '' "s/opt/workspace/g" $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libarchive.tar.xz -C $DIR/opt .