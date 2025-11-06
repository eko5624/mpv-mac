#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    prefix="$DIR/opt"
)

if [[ ("$(uname -m)" == "x86_64") && ("$ARCHS" == "arm64") ]]; then
    myconf+=(
        OUT=build
        CC="xcrun -sdk macosx clang"
        CFLAGS="-arch arm64 -mmacosx-version-min=11.0"
        LDFLAGS="-arch arm64 -mmacosx-version-min=11.0"
    )
fi

if [[ ("$(uname -m)" == "arm64") && ("$ARCHS" == "x86_64") ]]; then
    myconf+=(
        OUT=build
        CC="xcrun -sdk macosx clang"
        CFLAGS="-arch x86_64 -mmacosx-version-min=11.0"
        LDFLAGS="-arch x86_64 -mmacosx-version-min=11.0"
    )
fi

# Embeddable Javascript interpreter
cd $PACKAGES
git clone https://codeberg.org/ccxvii/mujs.git --branch "$VER_MUJS"
cd mujs
curl -OL https://raw.githubusercontent.com/shinchiro/mpv-winbuild-cmake/master/packages/mujs-0001-add-exe-to-binary-name.patch
patch -p1 -i mujs-0001-add-exe-to-binary-name.patch
mkdir build
make "${myconf[@]}"
make "${myconf[@]}" install

#workaround Could not resolve library: build/release/libmujs.dylib
#sudo install_name_tool -id "$DIR/opt/lib/libmujs.dylib" "$DIR/opt/lib/libmujs.dylib"

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf mujs.tar.xz -C $DIR/opt .
