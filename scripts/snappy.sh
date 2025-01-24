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
    -DSNAPPY_BUILD_TESTS=OFF
    -DSNAPPY_BUILD_BENCHMARKS=OFF
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

# Compression/decompression library aiming for high speed
cd $PACKAGES
git clone https://github.com/google/snappy.git --branch main
#Fixed comparison between signed and unsigned integer
#curl -OL https://patch-diff.githubusercontent.com/raw/google/snappy/pull/128.patch
#execute patch -p1 -i 128.patch
cd snappy
mkdir out && cd out
cmake .. -G "Ninja" "${myconf[@]}"
cmake --build . -j $MJOBS
cmake --install .

cd $DIR
tar -zcvf snappy.tar.xz -C $DIR/opt .
