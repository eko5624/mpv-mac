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
	-DMVK_CONFIG_LOG_LEVEL=error
	-DMVK_USE_METAL_PRIVATE_API=ON
	-DCPM_SOURCE_CACHE=src/CPM
	-Wno-dev
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

# Implementation of the Vulkan graphics and compute API on top of Metal
cd $PACKAGES
git clone https://github.com/KhronosGroup/MoltenVK.git --branch main
cd MoltenVK
# Fix CMake failing to fetch dependencies that have changed
curl -OL https://patch-diff.githubusercontent.com/raw/KhronosGroup/MoltenVK/pull/2662.patch
patch -p1 -i 2662.patch
mkdir out && cd out
cmake .. -G "Ninja" "${myconf[@]}"
cmake --build . -j $MJOBS
cmake --install .

# Force 11 deployment target for all homebrew formulas
#find $(brew --repository)/Library/Taps -type f -iname *rb -exec sed -i "" $'s/def install/def install\\\n    ENV["MACOSX_DEPLOYMENT_TARGET"] = "11"\\\n/' {} \;          
#brew install molten-vk

cd $DIR
#tar -zcvf molten-vk.tar.xz -C `brew --prefix molten-vk` .
tar -zcvf molten-vk.tar.xz -C $DIR/opt .
