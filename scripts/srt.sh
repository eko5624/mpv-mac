#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    -DCMAKE_INSTALL_PREFIX="$DIR/opt"
    -DCMAKE_OSX_ARCHITECTURES=$ARCHS
    -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOSX_TARGET
    -DCMAKE_INSTALL_NAME_DIR="$DIR/opt/lib"
    -DCMAKE_FIND_ROOT_PATH="$WORKSPACE"
    -DCMAKE_INSTALL_LIBDIR=lib
    -DCMAKE_INSTALL_BINDIR=bin
    -DCMAKE_INSTALL_INCLUDEDIR=include
    -DBUILD_SHARED_LIBS=OFF
    -DENABLE_SHARED=OFF
    -DENABLE_APPS=OFF
    -DENABLE_STATIC=ON
    -DUSE_STATIC_LIBSTDCXX=ON
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

# Secure Reliable Transport
# depends on: openssl(zlib)
cd $PACKAGES
git clone https://github.com/Haivision/srt.git
cd srt
export OPENSSL_ROOT_DIR="${WORKSPACE}"
export OPENSSL_LIB_DIR="${WORKSPACE}"/lib
export OPENSSL_INCLUDE_DIR="${WORKSPACE}"/include/
mkdir out && cd out
cmake .. -G "Ninja" "${myconf[@]}"
cmake --build . -j $MJOBS
cmake --install .

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf srt.tar.xz -C $DIR/opt .