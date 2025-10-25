#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --prefix="$DIR/opt"
    --buildtype=release
    --default-library=static
    -Dwrap_mode=nodownload
    -Db_lto=true
    -Db_lto_mode=thin
    -Dvulkan-registry="${WORKSPACE}"/share/vulkan/registry/vk.xml
    -Dvulkan=enabled
    -Dshaderc=enabled
    -Dlcms=enabled
    -Dopengl=enabled
    -Dd3d11=disabled
    -Dglslang=disabled
    -Ddemos=false
    -Ddemos=false
)

if [[ ("$(uname -m)" == "x86_64") && ("$ARCHS" == "arm64") ]]; then
    myconf+=(
        --cross-file=$DIR/meson_arm64.txt
    )
fi

if [[ ("$(uname -m)" == "arm64") && ("$ARCHS" == "x86_64") ]]; then
    myconf+=(
        --cross-file=$DIR/meson_x86_64.txt
    )
fi

# A Free Implementation of the Unicode Bidirectional Algorithm
#depends on: vulkan, lcms2(libjpeg-turbo, libtiff(libjpeg-turbo, zlib, zstd(lz4, xz, zlib), xz)), shaderc
cd $PACKAGES
git clone --recursive https://github.com/haasn/libplacebo.git
cd libplacebo
meson setup build "${myconf[@]}"
meson compile -C build
meson install -C build

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libplacebo.tar.xz -C $DIR/opt .
