#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Generic-purpose lossless compression algorithm by Google
cd $PACKAGES
git clone https://github.com/google/brotli.git

myconf=(
    -DCMAKE_INSTALL_PREFIX="$DIR/opt"
    -DCMAKE_OSX_ARCHITECTURES=$ARCHS
    -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOSX_TARGET
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_NAME_DIR="$DIR/opt/lib"
    -DBUILD_SHARED_LIBS=OFF
    -DBROTLI_EMSCRIPTEN=OFF
    -DBROTLI_BUILD_TOOLS=OFF
)

if [[ ("$(uname -m)" == "x86_64") && ("$ARCHS" != "x86_64") ]] || [[ ("$(uname -m)" == "arm64") && ("$ARCHS" != "arm64") ]]; then
    myconf+=(
        -DCMAKE_TOOLCHAIN_FILE=$DIR/cmake_$ARCHS.txt
    )
fi

cd brotli
mkdir out && cd out
cmake .. -G "Ninja" "${myconf[@]}"
cmake --build . -j $MJOBS
cmake --install .

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf brotli.tar.xz -C $DIR/opt .
