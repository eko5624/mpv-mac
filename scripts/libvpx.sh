#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --prefix="$DIR/opt"
    --disable-dependency-tracking
    --disable-examples
    --disable-unit-tests
    --disable-shared
    --disable-runtime-cpu-detect
    --enable-static
    --enable-pic
    --enable-vp9-highbitdepth
    --as=nasm
)

if [[ ("$(uname -m)" == "x86_64") && ("$ARCHS" == "arm64") ]]; then
    myconf+=(
        --target=arm64-darwin20-gcc
    )
fi

if [[ ("$(uname -m)" == "arm64") && ("$ARCHS" == "x86_64") ]]; then
    myconf+=(
        --target=x86_64-darwin20-gcc
    )
fi

# VP8/VP9 video codec
cd $PACKAGES
git clone https://chromium.googlesource.com/webm/libvpx.git
cd libvpx
echo "Applying Darwin patch"
sed "s/,--version-script//g" build/make/Makefile >build/make/Makefile.patched
sed "s/-Wl,--no-undefined -Wl,-soname/-Wl,-undefined,error -Wl,-install_name/g" build/make/Makefile.patched >build/make/Makefile
cd build
../configure "${myconf[@]}"
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libvpx.tar.xz -C $DIR/opt .