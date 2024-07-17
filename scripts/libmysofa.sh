#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

#depends on: zlib
# Reader for AES SOFA files to get better HRTFs
cd $PACKAGES
git clone --depth 1 --sparse --filter=tree:0 https://github.com/hoene/libmysofa.git
cd libmysofa
git sparse-checkout set --no-cone '/*' '!tests'
mkdir out && cd out
cmake .. \
  -G "Ninja" \
  -DCMAKE_INSTALL_PREFIX="$DIR/opt" \
  -DCMAKE_INSTALL_NAME_DIR="$DIR/opt/lib" \
  -DCMAKE_FIND_ROOT_PATH="$WORKSPACE" \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
  -DBUILD_TESTS=OFF
cmake --build . -j $MJOBS
cmake --install .

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libmysofa.tar.xz -C $DIR/opt .