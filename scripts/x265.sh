#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# H.265/HEVC encoder
cd $PACKAGES
git clone https://bitbucket.org/multicoreware/x265_git.git

# 10-bit
cd x265_git
mkdir out-10 && cd out-10
cmake ../source \
  -G "Ninja" \
  -DCMAKE_INSTALL_PREFIX="$DIR/opt" \
  -DCMAKE_BUILD_TYPE=Release \
  -DHIGH_BIT_DEPTH=ON \
  -DENABLE_HDR10_PLUS=ON \
  -DEXPORT_C_API=OFF \
  -DENABLE_CLI=OFF \
  -DENABLE_SHARED=OFF \
  -DBUILD_SHARED_LIBS=OFF
cmake --build .
cd ..

# 12-bit
mkdir out-12 && cd out-12
cmake ../source \
  -G "Ninja" \
  -DCMAKE_INSTALL_PREFIX="$DIR/opt" \
  -DCMAKE_INSTALL_NAME_DIR="$DIR/opt/lib" \
  -DCMAKE_BUILD_TYPE=Release \
  -DHIGH_BIT_DEPTH=ON \
  -DENABLE_HDR10_PLUS=ON \
  -DMAIN12=ON \
  -DEXPORT_C_API=OFF \
  -DENABLE_CLI=OFF \
  -DENABLE_SHARED=OFF \
  -DBUILD_SHARED_LIBS=OFF
cmake --build .
cd ..

# 8-bit
mkdir out-8 && cd out-8
mv ../out-10/libx265.a libx265_main10.a
mv ../out-12/libx265.a libx265_main12.a
cmake ../source \
  -G "Ninja" \
  -DCMAKE_INSTALL_PREFIX="$DIR/opt" \
  -DCMAKE_INSTALL_NAME_DIR="$DIR/opt/lib" \
  -DCMAKE_BUILD_TYPE=Release \
  -DEXTRA_LIB='x265_main10.a;x265_main12.a;-ldl' \
  -DEXTRA_LINK_FLAGS='-L.' \
  -DLINKED_10BIT=ON \
  -DLINKED_12BIT=ON \
  -DENABLE_CLI=OFF \
  -DENABLE_SHARED=OFF \
  -DBUILD_SHARED_LIBS=OFF
cmake --build . -j $MJOBS

# merge
mv libx265.a libx265_main.a
/usr/bin/libtool -static -o libx265.a libx265_main.a libx265_main10.a libx265_main12.a 2>/dev/null
cmake --install .

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf x265.tar.xz -C $DIR/opt .
