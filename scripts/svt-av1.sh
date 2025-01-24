#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    -DCMAKE_INSTALL_PREFIX="$DIR/opt"
    -DCMAKE_OSX_ARCHITECTURES=$ARCHS
    -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOSX_TARGET
    -DCMAKE_INSTALL_NAME_DIR="$DIR/opt/lib"
    -DCMAKE_BUILD_TYPE=Release
    -DBUILD_SHARED_LIBS=OFF
    -DBUILD_TESTING=OFF
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

# AV1 encoder
cd $PACKAGES
git clone https://gitlab.com/AOMediaCodec/SVT-AV1.git
cd SVT-AV1
# revert release v2.3.0 temporarily
git reset --hard 6e69def4ec283fe0b71195671245c3b768bebdef
mkdir out && cd out
cmake .. -G "Ninja" "${myconf[@]}"
cmake --build .
cmake --install .

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf svt-av1.tar.xz -C $DIR/opt .
