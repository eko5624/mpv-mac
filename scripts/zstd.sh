#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --prefix="$DIR/opt"
    --default-library=static
    -Dwrap_mode=nodownload
    -Dbuildtype=release
	-Db_lto=true
	-Db_lto_mode=thin
	-Dzlib=enabled
	-Dlzma=enabled
	-Dlz4=enabled
	-Dbin_programs=false
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

# Zstandard is a real-time compression algorithm
# depends on: lz4, xz, zlib
cd $PACKAGES
git clone https://github.com/facebook/zstd.git --branch dev
cd zstd
meson setup out build/meson "${myconf[@]}"
meson compile -C out
meson install -C out

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf zstd.tar.xz -C $DIR/opt .