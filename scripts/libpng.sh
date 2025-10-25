#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    -DCMAKE_INSTALL_PREFIX="$DIR/opt"
    -DCMAKE_OSX_ARCHITECTURES=$ARCHS
    -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOSX_TARGET
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_NAME_DIR="$DIR/opt/lib"
    -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON
    -DSKIP_INSTALL_EXPORT=ON
    -DPNG_SHARED=OFF
    -DPNG_FRAMEWORK=OFF
    -DPNG_TESTS=OFF
    -DPNG_TOOLS=OFF

if [[ ("$(uname -m)" == "x86_64") && ("$ARCHS" == "arm64") ]]; then
    myconf+=(
        -DCMAKE_TOOLCHAIN_FILE=$DIR/cmake_arm64.txt
    )
fi

if [[ ("$(uname -m)" == "arm64") && ("$ARCHS" == "x86_64") ]]; then
    myconf+=(
        -DCMAKE_TOOLCHAIN_FILE=$DIR/cmake_x86_64.txt
    )
fi

# Library for manipulating PNG images
#depends on: zlib
cd $PACKAGES
git clone https://github.com/glennrp/libpng.git
cd libpng
mkdir out && cd out
cmake .. -G "Ninja" "${myconf[@]}"
cmake --build . -j $MJOBS
cmake --install .

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/libpng16.pc

cd $DIR
tar -zcvf libpng.tar.xz -C $DIR/opt .
