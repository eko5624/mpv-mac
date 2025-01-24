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

# Vulkan Header and Loader
cd $PACKAGES
git clone https://github.com/KhronosGroup/Vulkan-Headers.git --branch main
git clone https://github.com/KhronosGroup/Vulkan-Loader.git --branch main

cd Vulkan-Headers
mkdir out && cd out
cmake .. -G "Ninja" "${myconf[@]}"
cmake --install .

cd $PACKAGES/Vulkan-Loader
mkdir out && cd out
cmake .. -G "Ninja" "${myconf[@]}" \
  -DCMAKE_FIND_ROOT_PATH="$DIR/opt" \
  -DVULKAN_HEADERS_INSTALL_DIR="$DIR/opt" \
  -DBUILD_TESTS=OFF \
  -DENABLE_WERROR=OFF
cmake --build .
cmake --install .
#sed -i "" 's/lvulkan/lMoltenVK/g' "$DIR/opt/lib/pkgconfig/vulkan.pc"

cd $DIR
tar -zcvf vulkan.tar.xz -C $DIR/opt .
