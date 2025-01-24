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
    -DBUILD_SHARED_LIBS=OFF
)

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

# Library for sample rate conversion of audio data
cd $PACKAGES
git clone https://github.com/libsndfile/libsamplerate.git
cd libsamplerate
mkdir out && cd out
cmake .. -G "Ninja" "${myconf[@]}"
cmake --build . -j $MJOBS
cmake --install .

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libsamplerate.tar.xz -C $DIR/opt .
