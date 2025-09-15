#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    -DCMAKE_INSTALL_PREFIX="$DIR/opt"
    -DCMAKE_INSTALL_NAME_DIR="$DIR/opt/lib"
    -DCMAKE_OSX_ARCHITECTURES=$ARCHS
    -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOSX_TARGET
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5
)

if [[ ("$(uname -m)" == "x86_64") && ("$ARCHS" == "arm64") ]]; then
    myconf+=(
        -DCMAKE_TOOLCHAIN_FILE=$DIR/cmake_arm64.txt
        -DENABLE_NEON=OFF
    )
fi

if [[ ("$(uname -m)" == "arm64") && ("$ARCHS" == "x86_64") ]]; then
    myconf+=(
        -DCMAKE_TOOLCHAIN_FILE=$DIR/cmake_x86_64.txt
    )
fi

# H.265/HEVC encoder
cd $PACKAGES
git clone https://bitbucket.org/multicoreware/x265_git.git

# Fix cross build x265 arm64 library on x86_64 macOS, add '-DENABLE_NEON=OFF'
# 10-bit
cd x265_git
# revert release v4.1 temporarily
git reset --hard 1d117bed4747
mkdir out-10 && cd out-10
cmake ../source \
  -G "Ninja" "${myconf[@]}" \
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
  -G "Ninja" "${myconf[@]}" \
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
  -G "Ninja" "${myconf[@]}" \
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
