#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --prefix="$DIR/opt"
    --disable-dependency-tracking
    --disable-silent-rules
    --without-x
    --disable-shared
    --enable-static
)

if [[ ("$(uname -m)" == "x86_64") && ("$ARCHS" == "arm64") ]]; then
    myconf+=(
        --host=aarch64-apple-darwin
        --target=arm64-apple-macos11.0
    )
    export ac_cv_func_malloc_0_nonnull=yes  # fix for the "missing _rpl_realloc() symbol" issue when cross-linking
    export ac_cv_func_realloc_0_nonnull=yes # fix for the "missing _rpl_realloc() symbol" issue when cross-linking 
fi

if [[ ("$(uname -m)" == "arm64") && ("$ARCHS" == "x86_64") ]]; then
    myconf+=(
        --host=x86_64-apple-darwin
        --target=x86_64-apple-macos11.0
    )
    export ac_cv_func_malloc_0_nonnull=yes  # fix for the "missing _rpl_realloc() symbol" issue when cross-linking
    export ac_cv_func_realloc_0_nonnull=yes # fix for the "missing _rpl_realloc() symbol" issue when cross-linking 
fi

# A VBI decoding library which can be used by FFmpeg to decode DVB teletext pages and DVB teletext subtitles
# depends on: libpng(zlib)
rm $DIR/workspace/lib/*.la
cd $PACKAGES
git clone https://github.com/zapping-vbi/zvbi.git --branch main

cd zvbi
./autogen.sh
./configure "${myconf[@]}"
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf zvbi.tar.xz -C $DIR/opt .