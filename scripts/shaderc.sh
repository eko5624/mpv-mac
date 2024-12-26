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
    -DCMAKE_FIND_ROOT_PATH="$DIR/opt"
    -DBUILD_SHARED_LIBS=OFF
    -DSHADERC_SKIP_TESTS=ON
    -DSKIP_GLSLANG_INSTALL=ON
    -DENABLE_SPIRV_TOOLS_INSTALL=ON
    -DSKIP_GOOGLETEST_INSTALL=ON
    -DSHADERC_SKIP_EXAMPLES=ON
    -DSPIRV_TOOLS_BUILD_STATIC=ON
    -DSPIRV_TOOLS_LIBRARY_TYPE=STATIC
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

# Collection of tools, libraries, and tests for Vulkan shader compilation
cd $PACKAGES
git clone https://github.com/google/shaderc.git
cp shaderc/DEPS ./
curl -OL https://github.com/KhronosGroup/glslang/archive/`cat DEPS | grep glslang | head -n1 | cut -d\' -f4`.tar.gz
curl -OL https://github.com/KhronosGroup/SPIRV-Headers/archive/`cat DEPS | grep spirv_headers | head -n1 | cut -d\' -f4`.tar.gz
curl -OL https://github.com/KhronosGroup/SPIRV-Tools/archive/`cat DEPS | grep spirv_tools | head -n1 | cut -d\' -f4`.tar.gz
for f in *.gz; do tar xvf "$f" 2>/dev/null >/dev/null; done
mv glslang* glslang 2>/dev/null >/dev/null
mv SPIRV-Headers* spirv-headers 2>/dev/null >/dev/null
mv SPIRV-Tools* spirv-tools 2>/dev/null >/dev/null
cd shaderc
mv $WORKSPACE/bin/libtool $WORKSPACE/bin/libtool.bak || true
sed -i "" 's/${SHADERC_SKIP_INSTALL}/ON/g' third_party/CMakeLists.txt
mv $PACKAGES/spirv-headers third_party 2>/dev/null >/dev/null
mv $PACKAGES/spirv-tools third_party 2>/dev/null >/dev/null
mv $PACKAGES/glslang third_party 2>/dev/null >/dev/null
mkdir out && cd out
cmake .. -G "Ninja" "${myconf[@]}"
cmake --build . -j $MJOBS

cd ..
mkdir -p $DIR/opt/lib/pkgconfig
cp -r libshaderc/include $DIR/opt
cp -r libshaderc_util/include/libshaderc_util $DIR/opt/include
cp out/libshaderc/libshaderc_combined.a $DIR/opt/lib
cp out/shaderc_combined.pc $DIR/opt/lib/pkgconfig/shaderc.pc
sed -i "" 's/-lshaderc_combined/-lshaderc_combined -lstdc++/g' $DIR/opt/lib/pkgconfig/shaderc.pc

mv $WORKSPACE/bin/libtool.bak $WORKSPACE/bin/libtool || true
sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf shaderc.tar.xz -C $DIR/opt .
