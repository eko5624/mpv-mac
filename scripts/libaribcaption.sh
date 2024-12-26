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
    -DBUILD_TESTING=OFF
    -DARIBCC_BUILD_TESTS=OFF
    -DARIBCC_SHARED_LIBRARY=OFF
    -DARIBCC_NO_RTTI=ON
    -DCMAKE_C_FLAGS='-DHAVE_OPENSSL=1'
    -DCMAKE_CXX_FLAGS='-DHAVE_OPENSSL=1'
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

# Portable ARIB STD-B24 Caption Decoder/Renderer
# depends on: fontconfig(expat, bzip2, freetype2, gettext(libxml2 ncurses)
# depends on: freetype2(bzip2, libpng(zlib))
cd $PACKAGES
git clone https://github.com/xqq/libaribcaption.git
cd libaribcaption
ln -s ${WORKSPACE}/include/openssl include/openssl
mkdir out && cd out
cmake .. -G "Ninja" "${myconf[@]}"
cmake --build . -j $MJOBS
cmake --install .

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libaribcaption.tar.xz -C $DIR/opt .
