#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# An opensource and cross-platform avs3 decoder, supports AVS3-P2 baseline profile
cd $PACKAGES
git clone https://github.com/uavs3/uavs3d.git --branch master
cd uavs3d
mkdir -p build/linux && cd build/linux
cmake ../.. \
  -G "Ninja" \
  -DCMAKE_INSTALL_PREFIX="$DIR/opt" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_NAME_DIR="$DIR/opt/lib" \
  -DBUILD_SHARED_LIBS=OFF \
  -DCOMPILE_10BIT=ON
cmake --build . -j $MJOBS
cmake --install .

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf uavs3d.tar.xz -C $DIR/opt .