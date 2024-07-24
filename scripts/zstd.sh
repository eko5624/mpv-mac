#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Zstandard is a real-time compression algorithm
# depends on: lz4, xz, zlib
cd $PACKAGES
git clone https://github.com/facebook/zstd.git --branch dev
cd zstd
mkdir out && cd out
cmake ../build/cmake \
  -G "Ninja" \
  -DCMAKE_INSTALL_PREFIX="$DIR/opt" \
  -DCMAKE_INSTALL_NAME_DIR="$DIR/opt/lib" \
  -DCMAKE_FIND_ROOT_PATH="$WORKSPACE" \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
	-DZSTD_BUILD_TESTS=OFF \
  -DZSTD_BUILD_SHARED=OFF \
  -DZSTD_BUILD_STATIC=ON \
	-DZSTD_PROGRAMS_LINK_SHARED=OFF \
	-DZSTD_BUILD_CONTRIB=ON \
	-DZSTD_LEGACY_SUPPORT=ON \
	-DZSTD_ZLIB_SUPPORT=ON \
	-DZSTD_LZMA_SUPPORT=ON \
	-DZSTD_LZ4_SUPPORT=ON \
	-DCMAKE_CXX_STANDARD=11 \
	-DZSTD_MULTITHREAD_SUPPORT=ON
cmake --build .
cmake --install .

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf zstd.tar.xz -C $DIR/opt .