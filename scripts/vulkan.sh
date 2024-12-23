#!/usr/local/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Get vulkan-loader version
which bash
declare -A ver_array
ver_json=$(curl -s "https://raw.githubusercontent.com/eko5624/nginx-nosni/master/old.json")
while IFS="=" read -r k v; do
  ver_array[$k]=$v
done < <(echo "$ver_json" | jq -r 'to_entries | .[] | "\(.key)=\(.value)"')
VER_VULKAN=$(echo "${ver_array[data]}" | jq -r '."vulkan-loader".version')

# Vulkan Header and Loader
cd $PACKAGES
git clone https://github.com/KhronosGroup/Vulkan-Headers.git --branch main
git clone https://github.com/KhronosGroup/Vulkan-Loader.git --branch main

cd Vulkan-Headers
mkdir out && cd out
cmake .. \
  -G "Ninja" \
  -DCMAKE_INSTALL_PREFIX="$DIR/opt" \
  -DCMAKE_TOOLCHAIN_FILE="$DIR/cmake_$ARCHS.txt" \
  -DCMAKE_OSX_ARCHITECTURES=$ARCHS \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOSX_TARGET \
  -DCMAKE_INSTALL_NAME_DIR="$DIR/opt/lib" \
  -DCMAKE_BUILD_TYPE=Release
cmake --install .

cd $PACKAGES/Vulkan-Loader
mkdir out && cd out
cmake .. \
  -G "Ninja" \
  -DCMAKE_INSTALL_PREFIX="$DIR/opt" \
  -DCMAKE_TOOLCHAIN_FILE="$DIR/cmake_$ARCHS.txt" \
  -DCMAKE_OSX_ARCHITECTURES=$ARCHS \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOSX_TARGET \
  -DCMAKE_INSTALL_NAME_DIR="$DIR/opt/lib" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_FIND_ROOT_PATH="$DIR/opt" \
  -DVULKAN_HEADERS_INSTALL_DIR="$DIR/opt" \
  -DBUILD_SHARED_LIBS=OFF \
  -DAPPLE_STATIC_LOADER=ON \
  -DBUILD_TESTS=OFF \
  -DENABLE_WERROR=OFF
cmake --build .
cmake --install .

mkdir -p $DIR/opt/lib/pkgconfig
cp loader/libvulkan.a $DIR/opt/lib
cp $DIR/vulkan.pc $DIR/opt/lib/pkgconfig
sed -i "" 's|@prefix@|'"${WORKSPACE}"'|g' $DIR/opt/lib/pkgconfig/vulkan.pc
sed -i "" 's|@VULKAN_LOADER_VERSION@|'"${VER_VULKAN}"'|g' $DIR/opt/lib/pkgconfig/vulkan.pc
cat $DIR/opt/lib/pkgconfig/vulkan.pc

cd $DIR
tar -zcvf vulkan.tar.xz -C $DIR/opt .
